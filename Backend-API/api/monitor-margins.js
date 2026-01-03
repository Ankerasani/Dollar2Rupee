/**
 * Automated Margin Monitoring Endpoint
 * 
 * This endpoint runs automatically via Vercel Cron to:
 * 1. Analyze current provider margins
 * 2. Compare to configured margins
 * 3. Alert if significant changes detected
 * 4. Log results for review
 * 
 * Schedule: Weekly (recommended)
 * Alert threshold: 0.5 INR change
 */

const axios = require('axios');

// Current configured margins (update these when you deploy new margins)
const CURRENT_MARGINS = {
  'transferwise': 0.0,
  'instarem': -0.21,
  'westernunion': -0.15,
  'statebank': -0.30,
  'moneygram': -0.36,
  'remitly': -0.53,
  'xoom': -1.06,
  'ofx': -2.71,
  'ria': -4.5
};

// Alert threshold (INR)
const ALERT_THRESHOLD = 0.5;

// Currencies to check
const CURRENCIES = ['USD', 'GBP', 'EUR'];

/**
 * Fetch forex rate
 */
async function getForexRate(sourceCurrency) {
  try {
    // Try Wise API first
    const wiseResponse = await axios.get('https://api.wise.com/v4/comparisons', {
      params: {
        sourceCurrency: sourceCurrency,
        targetCurrency: 'INR',
        sendAmount: 1000
      },
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'RemittanceCompare/1.0'
      },
      timeout: 15000
    });

    const midMarketProvider = wiseResponse.data.providers.find(p => 
      p.quotes?.[0]?.isConsideredMidMarketRate
    );
    
    if (midMarketProvider) {
      return midMarketProvider.quotes[0].rate;
    }

    // Fallback to Frankfurter
    const frankfurterResponse = await axios.get(
      `https://api.frankfurter.app/latest?from=${sourceCurrency}&to=INR`
    );
    return frankfurterResponse.data.rates.INR;

  } catch (error) {
    console.error(`Failed to get forex for ${sourceCurrency}:`, error.message);
    return null;
  }
}

/**
 * Fetch provider rates from Wise API
 */
async function getProviderRates(sourceCurrency) {
  try {
    const response = await axios.get('https://api.wise.com/v4/comparisons', {
      params: {
        sourceCurrency: sourceCurrency,
        targetCurrency: 'INR',
        sendAmount: 1000
      },
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'RemittanceCompare/1.0'
      },
      timeout: 15000
    });

    const providerMap = {
      'wise': 'transferwise',
      'xoom': 'xoom',
      'remitly': 'remitly',
      'moneygram': 'moneygram',
      'instarem': 'instarem',
      'state-bank-of-india': 'statebank',
      'ofx': 'ofx',
      'western-union': 'westernunion',
      'ria': 'ria'
    };

    const providers = [];
    response.data.providers.forEach(provider => {
      const alias = provider.alias.toLowerCase();
      const mappedName = providerMap[alias];
      
      if (provider.quotes && provider.quotes.length > 0 && mappedName) {
        providers.push({
          name: mappedName,
          rate: provider.quotes[0].rate
        });
      }
    });

    return providers;

  } catch (error) {
    console.error(`Failed to get providers for ${sourceCurrency}:`, error.message);
    return [];
  }
}

/**
 * Analyze margins for a currency
 */
async function analyzeCurrency(currency) {
  const forexRate = await getForexRate(currency);
  if (!forexRate) {
    return { success: false, currency, error: 'Could not fetch forex rate' };
  }

  const providers = await getProviderRates(currency);
  if (providers.length === 0) {
    return { success: false, currency, error: 'Could not fetch provider rates' };
  }

  const analysis = [];
  
  providers.forEach(provider => {
    const actualMargin = parseFloat((provider.rate - forexRate).toFixed(2));
    const configuredMargin = CURRENT_MARGINS[provider.name];
    
    if (configuredMargin !== undefined) {
      const difference = Math.abs(actualMargin - configuredMargin);
      
      analysis.push({
        provider: provider.name,
        currentMargin: configuredMargin,
        actualMargin: actualMargin,
        difference: parseFloat(difference.toFixed(2)),
        needsUpdate: difference >= ALERT_THRESHOLD
      });
    }
  });

  return {
    success: true,
    currency,
    forexRate,
    analysis: analysis.sort((a, b) => b.difference - a.difference)
  };
}

/**
 * Main handler
 */
module.exports = async (req, res) => {
  // Only allow GET requests
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  console.log('🔍 Starting automated margin analysis...');
  console.log('⏰ Time:', new Date().toISOString());

  const results = [];
  const alerts = [];

  // Analyze each currency
  for (const currency of CURRENCIES) {
    console.log(`\n📊 Analyzing ${currency}...`);
    const result = await analyzeCurrency(currency);
    results.push(result);

    if (result.success) {
      // Check for alerts
      const needsUpdate = result.analysis.filter(a => a.needsUpdate);
      if (needsUpdate.length > 0) {
        alerts.push({
          currency: currency,
          providers: needsUpdate
        });
      }
    }

    // Wait between requests
    await new Promise(resolve => setTimeout(resolve, 2000));
  }

  // Generate summary
  const summary = {
    timestamp: new Date().toISOString(),
    alertThreshold: ALERT_THRESHOLD,
    currenciesChecked: CURRENCIES.length,
    providersMonitored: Object.keys(CURRENT_MARGINS).length,
    alertsTriggered: alerts.length,
    alerts: alerts,
    results: results
  };

  // Log summary
  console.log('\n' + '='.repeat(70));
  console.log('📊 MONITORING SUMMARY');
  console.log('='.repeat(70));
  console.log(`Time: ${summary.timestamp}`);
  console.log(`Currencies checked: ${summary.currenciesChecked}`);
  console.log(`Alerts triggered: ${summary.alertsTriggered}`);

  if (alerts.length > 0) {
    console.log('\n⚠️  ALERTS:');
    alerts.forEach(alert => {
      console.log(`\n${alert.currency}:`);
      alert.providers.forEach(p => {
        console.log(`  • ${p.provider}: ${p.currentMargin} → ${p.actualMargin} (diff: ${p.difference})`);
      });
    });
  } else {
    console.log('\n✅ No significant changes detected');
  }

  // Return response
  if (alerts.length > 0) {
    return res.status(200).json({
      status: 'warning',
      message: `${alerts.length} provider(s) need review`,
      ...summary
    });
  } else {
    return res.status(200).json({
      status: 'ok',
      message: 'All margins within acceptable range',
      ...summary
    });
  }
};

