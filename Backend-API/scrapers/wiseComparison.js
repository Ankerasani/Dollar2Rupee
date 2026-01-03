const axios = require('axios');

/**
 * FALLBACK STRATEGY:
 * 1. Try Wise Comparison API (best - 9 real providers)
 * 2. If fails, calculate all from Frankfurter forex rate
 * 3. If both fail, use cached data
 * 4. If no cache, use emergency static rates
 */

/**
 * Emergency static rates (last resort - based on typical market rates)
 * Updated: Jan 2026
 */
const EMERGENCY_RATES = {
  forexRate: 90.0,
  rates: [
    { provider: 'transferwise', rate: 90.01, source: 'emergency-static' },
    { provider: 'remitly', rate: 89.70, source: 'emergency-static' },
    { provider: 'statebank', rate: 89.65, source: 'emergency-static' },
    { provider: 'moneygram', rate: 89.50, source: 'emergency-static' },
    { provider: 'instarem', rate: 89.55, source: 'emergency-static' },
    { provider: 'xoom', rate: 89.10, source: 'emergency-static' },
    { provider: 'westernunion', rate: 89.73, source: 'emergency-static' },  // Updated with real rate
    { provider: 'ria', rate: 85.50, source: 'emergency-static' },
    { provider: 'ofx', rate: 87.00, source: 'emergency-static' }
  ]
};

/**
 * Fetch real remittance rates from Wise Comparison API
 * @param {string} sourceCurrency - Source currency code (USD, GBP, EUR, etc.)
 */
async function fetchWiseComparison(sourceCurrency = 'USD') {
  try {
    console.log(`📡 [PRIMARY] Fetching from Wise Comparison API (${sourceCurrency} → INR)...`);
    
    const response = await axios.get(
      'https://api.wise.com/v4/comparisons',
      {
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
      }
    );
    
    const data = response.data;
    const rates = [];
    
    const providerMap = {
      'wise': 'transferwise',
      'xoom': 'xoom',
      'remitly': 'remitly',
      'moneygram': 'moneygram',
      'instarem': 'instarem',
      'state-bank-of-india': 'statebank',
      'ofx': 'ofx',
      'chase': 'chase',
      'wells-fargo': 'wellsfargo',
      'western-union': 'westernunion',
      'remit2india': 'remit2india',
      'ria': 'ria'
    };
    
    data.providers.forEach(provider => {
      const alias = provider.alias.toLowerCase();
      const mappedName = providerMap[alias];
      
      if (provider.quotes && provider.quotes.length > 0 && mappedName) {
        const quote = provider.quotes[0];
        rates.push({
          provider: mappedName,
          name: provider.name,
          rate: parseFloat(quote.rate.toFixed(2)),
          fee: quote.fee,
          receivedAmount: quote.receivedAmount,
          markup: quote.markup,
          timestamp: new Date().toISOString(),
          source: 'wise-api',
          deliveryTime: quote.deliveryEstimation,
          isMidMarket: quote.isConsideredMidMarketRate
        });
        
        const midMarketLabel = quote.isConsideredMidMarketRate ? ' (MID-MARKET)' : '';
        console.log(`  ✅ ${provider.name.padEnd(20)} ${quote.rate.toFixed(2)} INR${midMarketLabel}`);
      }
    });
    
    console.log(`  📊 Total: ${rates.length} providers\n`);
    
    return {
      success: true,
      rates: rates,
      count: rates.length,
      timestamp: new Date().toISOString()
    };
    
  } catch (error) {
    console.error(`  ❌ Wise API failed: ${error.message}\n`);
    return {
      success: false,
      rates: [],
      count: 0,
      error: error.message
    };
  }
}

/**
 * Get forex rate with fallback
 * @param {string} sourceCurrency - Source currency code (USD, GBP, EUR, etc.)
 */
async function getForexRate(sourceCurrency = 'USD') {
  try {
    // Try 1: Get from Wise Comparison (most accurate mid-market rate)
    console.log(`📡 [PRIMARY] Fetching forex from Wise API (${sourceCurrency} → INR)...`);
    const wiseComparison = await fetchWiseComparison(sourceCurrency);
    
    if (wiseComparison.success) {
      const wiseRate = wiseComparison.rates.find(r => r.provider === 'transferwise' && r.isMidMarket);
      if (wiseRate) {
        console.log(`  ✅ Forex: ${wiseRate.rate} INR (Wise mid-market)\n`);
        return {
          rate: wiseRate.rate,
          source: 'wise-api',
          timestamp: new Date().toISOString()
        };
      }
    }
    
    // Try 2: Fallback to Frankfurter
    console.log(`📡 [FALLBACK] Fetching forex from Frankfurter API (${sourceCurrency} → INR)...`);
    const response = await axios.get(`https://api.frankfurter.app/latest?from=${sourceCurrency}&to=INR`, {
      timeout: 10000,
      headers: {
        'User-Agent': 'Dollar2Rupee/1.0'
      }
    });
    
    console.log(`  ✅ Forex: ${response.data.rates.INR} INR (Frankfurter)\n`);
    return {
      rate: response.data.rates.INR,
      source: 'frankfurter',
      date: response.data.date,
      timestamp: new Date().toISOString()
    };
    
  } catch (error) {
    console.error(`  ❌ Both forex APIs failed: ${error.message}\n`);
    
    // Try 3: Emergency fallback
    console.log('📡 [EMERGENCY] Using static forex rate...');
    console.log(`  ⚠️  Forex: ${EMERGENCY_RATES.forexRate} INR (static fallback)\n`);
    return {
      rate: EMERGENCY_RATES.forexRate,
      source: 'emergency-static',
      timestamp: new Date().toISOString(),
      warning: 'Using emergency static rate - APIs unavailable'
    };
  }
}

/**
 * Calculate rates from forex rate
 */
function calculateAllRatesFromForex(forexRate) {
  console.log(`📐 [FALLBACK] Calculating all rates from Forex: ${forexRate} INR\n`);
  
  const providerMargins = {
    'transferwise': -3.0,
    'xoom': -3.5,
    'westernunion': -0.28,    // Updated based on real data: 89.73 INR
    'remitly': -3.3,
    'instarem': -3.4,
    'ria': -4.5,
    'statebank': -3.5,
    'ofx': -3.9,
    'moneygram': -3.6
  };
  
  const rates = [];
  const timestamp = new Date().toISOString();
  
  Object.entries(providerMargins).forEach(([provider, margin]) => {
    const rate = parseFloat((forexRate + margin).toFixed(2));
    rates.push({
      provider: provider,
      rate: rate,
      timestamp: timestamp,
      source: 'calculated-forex'
    });
    console.log(`  • ${provider.padEnd(15)} ${rate.toFixed(2)} INR`);
  });
  
  console.log(`  📊 Total: ${rates.length} providers (all calculated)\n`);
  return rates;
}

/**
 * Calculate rates for missing providers
 */
function calculateMissingRates(forexRate, existingProviders) {
  const allProviders = ['transferwise', 'xoom', 'westernunion', 'remitly', 
                        'instarem', 'ria', 'statebank', 'ofx', 'moneygram'];
  
  const missingProviders = allProviders.filter(p => !existingProviders.includes(p));
  
  if (missingProviders.length === 0) {
    return [];
  }
  
  console.log(`📐 Calculating ${missingProviders.length} missing providers from Forex: ${forexRate} INR\n`);
  
  const providerMargins = {
    'transferwise': -3.0,
    'xoom': -3.5,
    'westernunion': -0.28,    // Updated based on real data: 89.73 INR (90.01 - 0.28)
    'remitly': -3.3,
    'instarem': -3.4,
    'ria': -4.5,
    'statebank': -3.5,
    'ofx': -3.9,
    'moneygram': -3.6
  };
  
  const calculated = [];
  const timestamp = new Date().toISOString();
  
  missingProviders.forEach(provider => {
    if (providerMargins[provider]) {
      const rate = parseFloat((forexRate + providerMargins[provider]).toFixed(2));
      calculated.push({
        provider: provider,
        rate: rate,
        timestamp: timestamp,
        source: 'calculated-forex'
      });
      console.log(`  • ${provider.padEnd(15)} ${rate.toFixed(2)} INR`);
    }
  });
  
  console.log('');
  return calculated;
}

/**
 * Main function with comprehensive fallback strategy
 * @param {string} sourceCurrency - Source currency code (USD, GBP, EUR, etc.)
 */
async function getAllRates(sourceCurrency = 'USD') {
  console.log(`🔍 FETCHING RATES WITH FALLBACK STRATEGY (${sourceCurrency} → INR)\n`);
  console.log('='.repeat(70));
  console.log('Strategy: Wise API → Calculated → Cache → Emergency Static\n');
  console.log('='.repeat(70) + '\n');
  
  try {
    // STEP 1: Try Wise Comparison API
    const wiseData = await fetchWiseComparison(sourceCurrency);
    
    if (wiseData.success && wiseData.rates.length > 0) {
      // Wise API worked! Get forex and calculate missing providers
      const forexRate = await getForexRate(sourceCurrency);
      const existingProviders = wiseData.rates.map(r => r.provider);
      const calculatedRates = calculateMissingRates(forexRate.rate, existingProviders);
      const allRates = [...wiseData.rates, ...calculatedRates];
      
      console.log('='.repeat(70));
      console.log('✅ SUCCESS - Wise API + Calculated\n');
      console.log(`   Total: ${allRates.length} providers`);
      console.log(`   - Wise API: ${wiseData.rates.length}`);
      console.log(`   - Calculated: ${calculatedRates.length}\n`);
      console.log('='.repeat(70));
      
      return {
        success: true,
        forexRate: forexRate,
        rates: allRates,
        timestamp: new Date().toISOString(),
        count: allRates.length,
        sources: {
          wiseApi: wiseData.rates.length,
          calculated: calculatedRates.length,
          emergency: 0
        },
        fallbackLevel: 'none',
        sourceCurrency: sourceCurrency,
        targetCurrency: 'INR'
      };
    }
    
    // STEP 2: Wise API failed - Calculate all from Forex
    console.log('⚠️  Wise API failed - using Forex calculation fallback\n');
    const forexRate = await getForexRate(sourceCurrency);
    const calculatedRates = calculateAllRatesFromForex(forexRate.rate);
    
    console.log('='.repeat(70));
    console.log('✅ SUCCESS - All Calculated from Forex\n');
    console.log(`   Total: ${calculatedRates.length} providers`);
    console.log(`   - All calculated from ${forexRate.source}\n`);
    console.log('='.repeat(70));
    
    return {
      success: true,
      forexRate: forexRate,
      rates: calculatedRates,
      timestamp: new Date().toISOString(),
      count: calculatedRates.length,
      sources: {
        wiseApi: 0,
        calculated: calculatedRates.length,
        emergency: 0
      },
      fallbackLevel: 'forex-calculated',
      warning: 'Wise API unavailable - all rates calculated from forex',
      sourceCurrency: sourceCurrency,
      targetCurrency: 'INR'
    };
    
  } catch (error) {
    // STEP 3: Everything failed - use emergency static rates
    console.error('❌ ALL APIs FAILED:', error.message);
    console.log('\n🚨 [EMERGENCY] Using static fallback rates\n');
    
    console.log('='.repeat(70));
    console.log('⚠️  EMERGENCY MODE - Static Rates\n');
    console.log(`   Total: ${EMERGENCY_RATES.rates.length} providers`);
    console.log(`   - All from emergency static data\n`);
    console.log('='.repeat(70));
    
    return {
      success: true,
      forexRate: {
        rate: EMERGENCY_RATES.forexRate,
        source: 'emergency-static',
        timestamp: new Date().toISOString()
      },
      rates: EMERGENCY_RATES.rates.map(r => ({
        ...r,
        timestamp: new Date().toISOString()
      })),
      timestamp: new Date().toISOString(),
      count: EMERGENCY_RATES.rates.length,
      sources: {
        wiseApi: 0,
        calculated: 0,
        emergency: EMERGENCY_RATES.rates.length
      },
      fallbackLevel: 'emergency-static',
      warning: 'All APIs unavailable - using emergency static rates (may be outdated)',
      sourceCurrency: sourceCurrency,
      targetCurrency: 'INR'
    };
  }
}

module.exports = {
  fetchWiseComparison,
  getForexRate,
  getAllRates,
  EMERGENCY_RATES
};
