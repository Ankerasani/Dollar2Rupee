const axios = require('axios');

/**
 * FALLBACK STRATEGY:
 * 1. Try Wise Comparison API (best - 9 real providers)
 * 2. If fails, calculate all from Frankfurter forex rate
 * 3. If both fail, use cached data
 * 4. If no cache, use emergency static rates
 */

/**
 * Emergency static rates (last resort - based on real Wise API data)
 * Updated: Jan 2026 - Using actual margins from multi-currency analysis
 * Base forex rate: 90.0 INR (typical USD rate)
 */
const EMERGENCY_RATES = {
  forexRate: 90.0,
  rates: [
    { provider: 'transferwise', rate: 90.00, source: 'emergency-static' },  // Forex + 0.0
    { provider: 'instarem', rate: 89.79, source: 'emergency-static' },      // Forex - 0.21
    { provider: 'westernunion', rate: 89.85, source: 'emergency-static' },  // Forex - 0.15
    { provider: 'statebank', rate: 89.70, source: 'emergency-static' },     // Forex - 0.30
    { provider: 'moneygram', rate: 89.64, source: 'emergency-static' },     // Forex - 0.36
    { provider: 'remitly', rate: 89.47, source: 'emergency-static' },       // Forex - 0.53
    { provider: 'xoom', rate: 88.94, source: 'emergency-static' },          // Forex - 1.06
    { provider: 'ofx', rate: 87.29, source: 'emergency-static' },           // Forex - 2.71
    { provider: 'ria', rate: 85.50, source: 'emergency-static' }            // Forex - 4.5 (estimated)
  ]
};

/**
 * Fetch real remittance rates from Wise Comparison API
 * @param {string} sourceCurrency - Source currency code (USD, GBP, EUR, etc.)
 * @param {string} targetCurrency - Target currency code (INR, PHP, MXN, etc.)
 */
async function fetchWiseComparison(sourceCurrency = 'USD', targetCurrency = 'INR') {
  try {
    console.log(`📡 [PRIMARY] Fetching from Wise Comparison API (${sourceCurrency} → ${targetCurrency})...`);
    
    const response = await axios.get(
      'https://api.wise.com/v4/comparisons',
      {
        params: {
          sourceCurrency: sourceCurrency,
          targetCurrency: targetCurrency,
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
      'ria': 'ria',
      'bank-of-america': 'bankofamerica',
      'paypal': 'paypal',
      'world-remit': 'worldremit'
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
        console.log(`  ✅ ${provider.name.padEnd(20)} ${quote.rate.toFixed(2)} ${targetCurrency}${midMarketLabel}`);
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
 * @param {string} targetCurrency - Target currency code (INR, PHP, MXN, etc.)
 */
async function getForexRate(sourceCurrency = 'USD', targetCurrency = 'INR') {
  try {
    // Try 1: Get from Wise Comparison (most accurate mid-market rate)
    console.log(`📡 [PRIMARY] Fetching forex from Wise API (${sourceCurrency} → ${targetCurrency})...`);
    const wiseComparison = await fetchWiseComparison(sourceCurrency, targetCurrency);
    
    if (wiseComparison.success) {
      const wiseRate = wiseComparison.rates.find(r => r.provider === 'transferwise' && r.isMidMarket);
      if (wiseRate) {
        console.log(`  ✅ Forex: ${wiseRate.rate} ${targetCurrency} (Wise mid-market)\n`);
        return {
          rate: wiseRate.rate,
          source: 'wise-api',
          timestamp: new Date().toISOString()
        };
      }
    }
    
    // Try 2: Fallback to Frankfurter
    console.log(`📡 [FALLBACK] Fetching forex from Frankfurter API (${sourceCurrency} → ${targetCurrency})...`);
    const response = await axios.get(`https://api.frankfurter.app/latest?from=${sourceCurrency}&to=${targetCurrency}`, {
      timeout: 10000,
      headers: {
        'User-Agent': 'Dollar2Rupee/1.0'
      }
    });
    
    console.log(`  ✅ Forex: ${response.data.rates[targetCurrency]} ${targetCurrency} (Frankfurter)\n`);
    return {
      rate: response.data.rates[targetCurrency],
      source: 'frankfurter',
      date: response.data.date,
      timestamp: new Date().toISOString()
    };
    
  } catch (error) {
    console.error(`  ❌ Both forex APIs failed: ${error.message}\n`);
    
    // Try 3: Emergency fallback (only works for INR)
    if (targetCurrency === 'INR') {
      console.log('📡 [EMERGENCY] Using static forex rate...');
      console.log(`  ⚠️  Forex: ${EMERGENCY_RATES.forexRate} INR (static fallback)\n`);
      return {
        rate: EMERGENCY_RATES.forexRate,
        source: 'emergency-static',
        timestamp: new Date().toISOString(),
        warning: 'Using emergency static rate - APIs unavailable'
      };
    }
    
    throw new Error(`No fallback rate available for ${targetCurrency}`);
  }
}

/**
 * Calculate rates from forex rate
 * Updated margins based on real API analysis across 6 currencies (USD, GBP, EUR, CAD, AUD, SGD)
 * Analysis date: Jan 2026
 */
function calculateAllRatesFromForex(forexRate) {
  console.log(`📐 [FALLBACK] Calculating all rates from Forex: ${forexRate} INR\n`);
  
  // Real-world average margins from Wise API analysis
  const providerMargins = {
    'transferwise': 0.0,      // Wise: 0.01% (mid-market rate)
    'instarem': -0.21,        // Instarem: -0.25%
    'westernunion': -0.15,    // Western Union: -0.17%
    'statebank': -0.30,       // State Bank of India: -0.29%
    'moneygram': -0.36,       // Moneygram: -0.40%
    'remitly': -0.53,         // Remitly: -0.68%
    'xoom': -1.06,            // Xoom: -1.13%
    'ofx': -2.71,             // OFX: -3.15%
    'ria': -4.5               // RIA: estimated (not in Wise API)
  };
  
  const rates = [];
  const timestamp = new Date().toISOString();
  
  Object.entries(providerMargins).forEach(([provider, margin]) => {
    const rate = parseFloat((forexRate + margin).toFixed(2));
    const markup = parseFloat((Math.abs(margin) / forexRate * 100).toFixed(2));
    
    rates.push({
      provider: provider,
      rate: rate,
      fee: 0.0,  // No fee data for calculated rates
      markup: markup,
      timestamp: timestamp,
      source: 'calculated-forex'
    });
    console.log(`  • ${provider.padEnd(15)} ${rate.toFixed(2)} INR (markup: ${markup.toFixed(2)}%)`);
  });
  
  console.log(`  📊 Total: ${rates.length} providers (all calculated)\n`);
  return rates;
}

/**
 * Calculate rates for missing providers
 * Uses real-world average margins from API analysis
 */
function calculateMissingRates(forexRate, existingProviders) {
  const allProviders = ['transferwise', 'xoom', 'westernunion', 'remitly', 
                        'instarem', 'ria', 'statebank', 'ofx', 'moneygram'];
  
  const missingProviders = allProviders.filter(p => !existingProviders.includes(p));
  
  if (missingProviders.length === 0) {
    return [];
  }
  
  console.log(`📐 Calculating ${missingProviders.length} missing providers from Forex: ${forexRate} INR\n`);
  
  // Real-world average margins from Wise API analysis
  const providerMargins = {
    'transferwise': 0.0,      // Wise: 0.01% (mid-market rate)
    'instarem': -0.21,        // Instarem: -0.25%
    'westernunion': -0.15,    // Western Union: -0.17%
    'statebank': -0.30,       // State Bank of India: -0.29%
    'moneygram': -0.36,       // Moneygram: -0.40%
    'remitly': -0.53,         // Remitly: -0.68%
    'xoom': -1.06,            // Xoom: -1.13%
    'ofx': -2.71,             // OFX: -3.15%
    'ria': -4.5               // RIA: estimated (not in Wise API)
  };
  
  const calculated = [];
  const timestamp = new Date().toISOString();
  
  missingProviders.forEach(provider => {
    if (providerMargins[provider]) {
      const rate = parseFloat((forexRate + providerMargins[provider]).toFixed(2));
      const markup = parseFloat((Math.abs(providerMargins[provider]) / forexRate * 100).toFixed(2));
      
      // Estimated typical fees (will be 0 if using Wise API data)
      const typicalFees = {
        'transferwise': 11.72,
        'xoom': 4.99,
        'westernunion': 5.00,
        'remitly': 3.99,
        'instarem': 0.00,
        'ria': 5.00,
        'statebank': 0.00,
        'ofx': 5.00,
        'moneygram': 5.00
      };
      
      calculated.push({
        provider: provider,
        rate: rate,
        fee: 0.0,  // Set to 0 for calculated rates (no actual fee data)
        markup: markup,
        timestamp: timestamp,
        source: 'calculated-forex'
      });
      console.log(`  • ${provider.padEnd(15)} ${rate.toFixed(2)} INR (markup: ${markup.toFixed(2)}%)`);
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
