#!/usr/bin/env node

/**
 * Margin Analysis Script
 * 
 * This script:
 * 1. Fetches real rates from Wise API for multiple currencies
 * 2. Calculates the difference between forex rate and provider rates
 * 3. Generates accurate margin formulas for each provider
 * 4. Updates the backend with these margins for fallback calculations
 */

const axios = require('axios');

// All supported currencies
const CURRENCIES = ['USD', 'GBP', 'EUR', 'CAD', 'AUD', 'SGD'];

// Store all analysis results
const analysisResults = {
  currencies: {},
  providerMargins: {},
  summary: {}
};

/**
 * Fetch forex rate (mid-market rate)
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

    // Get mid-market rate from Wise
    const midMarketProvider = wiseResponse.data.providers.find(p => p.quotes?.[0]?.isConsideredMidMarketRate);
    if (midMarketProvider) {
      return midMarketProvider.quotes[0].rate;
    }

    // Fallback to Frankfurter
    const frankfurterResponse = await axios.get(`https://api.frankfurter.app/latest?from=${sourceCurrency}&to=INR`);
    return frankfurterResponse.data.rates.INR;

  } catch (error) {
    console.error(`❌ Failed to get forex rate for ${sourceCurrency}:`, error.message);
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
        const quote = provider.quotes[0];
        providers.push({
          name: mappedName,
          displayName: provider.name,
          rate: quote.rate,
          fee: quote.fee,
          isMidMarket: quote.isConsideredMidMarketRate || false
        });
      }
    });

    return providers;

  } catch (error) {
    console.error(`❌ Failed to get provider rates for ${sourceCurrency}:`, error.message);
    return [];
  }
}

/**
 * Calculate margin for a provider
 */
function calculateMargin(forexRate, providerRate) {
  // Margin = Provider Rate - Forex Rate
  // Negative means provider rate is worse than forex
  return parseFloat((providerRate - forexRate).toFixed(2));
}

/**
 * Calculate percentage difference
 */
function calculatePercentage(forexRate, providerRate) {
  return parseFloat((((providerRate - forexRate) / forexRate) * 100).toFixed(2));
}

/**
 * Analyze a single currency
 */
async function analyzeCurrency(currency) {
  console.log(`\n${'='.repeat(70)}`);
  console.log(`📊 ANALYZING ${currency} → INR`);
  console.log('='.repeat(70));

  const forexRate = await getForexRate(currency);
  if (!forexRate) {
    console.log(`❌ Could not get forex rate for ${currency}`);
    return null;
  }

  console.log(`\n💱 Forex Rate (Mid-Market): ${forexRate.toFixed(2)} INR`);

  const providers = await getProviderRates(currency);
  if (providers.length === 0) {
    console.log(`❌ No provider rates found for ${currency}`);
    return null;
  }

  console.log(`\n📋 Found ${providers.length} providers:\n`);

  const providerAnalysis = [];

  providers.forEach(provider => {
    const margin = calculateMargin(forexRate, provider.rate);
    const percentage = calculatePercentage(forexRate, provider.rate);

    providerAnalysis.push({
      name: provider.name,
      displayName: provider.displayName,
      rate: provider.rate,
      margin: margin,
      percentage: percentage,
      isMidMarket: provider.isMidMarket
    });

    const emoji = provider.isMidMarket ? '⭐' : (margin < 0 ? '❌' : '✅');
    const marginStr = (margin >= 0 ? `+${margin}` : `${margin}`).toString();
    const percentStr = (percentage >= 0 ? `+${percentage}%` : `${percentage}%`).toString();
    
    console.log(`${emoji} ${provider.displayName.padEnd(25)} ${provider.rate.toFixed(2)} INR   Margin: ${marginStr.padEnd(8)} (${percentStr})`);
  });

  return {
    forexRate: forexRate,
    providers: providerAnalysis
  };
}

/**
 * Analyze all currencies
 */
async function analyzeAllCurrencies() {
  console.log('\n╔══════════════════════════════════════════════════════════════════╗');
  console.log('║           PROVIDER MARGIN ANALYSIS - ALL CURRENCIES             ║');
  console.log('╚══════════════════════════════════════════════════════════════════╝');

  for (const currency of CURRENCIES) {
    const result = await analyzeCurrency(currency);
    if (result) {
      analysisResults.currencies[currency] = result;
    }
    // Wait a bit between requests
    await new Promise(resolve => setTimeout(resolve, 2000));
  }

  console.log('\n\n' + '='.repeat(70));
  console.log('📊 AVERAGE MARGINS ACROSS ALL CURRENCIES');
  console.log('='.repeat(70) + '\n');

  // Calculate average margins for each provider
  const providerData = {};

  Object.entries(analysisResults.currencies).forEach(([currency, data]) => {
    data.providers.forEach(provider => {
      if (!providerData[provider.name]) {
        providerData[provider.name] = {
          displayName: provider.displayName,
          margins: [],
          percentages: [],
          rates: []
        };
      }
      providerData[provider.name].margins.push(provider.margin);
      providerData[provider.name].percentages.push(provider.percentage);
      providerData[provider.name].rates.push(provider.rate);
    });
  });

  // Calculate averages
  Object.entries(providerData).forEach(([providerName, data]) => {
    const avgMargin = data.margins.reduce((a, b) => a + b, 0) / data.margins.length;
    const avgPercentage = data.percentages.reduce((a, b) => a + b, 0) / data.percentages.length;
    const minMargin = Math.min(...data.margins);
    const maxMargin = Math.max(...data.margins);

    analysisResults.providerMargins[providerName] = {
      displayName: data.displayName,
      averageMargin: parseFloat(avgMargin.toFixed(2)),
      averagePercentage: parseFloat(avgPercentage.toFixed(2)),
      minMargin: parseFloat(minMargin.toFixed(2)),
      maxMargin: parseFloat(maxMargin.toFixed(2)),
      dataPoints: data.margins.length
    };

    const marginStr = avgMargin >= 0 ? `+${avgMargin.toFixed(2)}` : avgMargin.toFixed(2);
    const percentStr = avgPercentage >= 0 ? `+${avgPercentage.toFixed(2)}%` : `${avgPercentage.toFixed(2)}%`;
    
    console.log(`${data.displayName.padEnd(25)} Avg: ${marginStr.padEnd(8)} (${percentStr})   Range: [${minMargin.toFixed(2)}, ${maxMargin.toFixed(2)}]`);
  });

  // Generate JavaScript code for margins
  console.log('\n\n' + '='.repeat(70));
  console.log('📋 UPDATED PROVIDER MARGINS FOR wiseComparison.js');
  console.log('='.repeat(70) + '\n');

  console.log('const providerMargins = {');
  Object.entries(analysisResults.providerMargins)
    .sort((a, b) => a[0].localeCompare(b[0]))
    .forEach(([providerName, data], index, array) => {
      const comma = index < array.length - 1 ? ',' : '';
      console.log(`  '${providerName}': ${data.averageMargin}${comma}  // ${data.displayName} (${data.averagePercentage}%)`);
    });
  console.log('};');

  // Save results to file
  const fs = require('fs');
  const outputPath = './margin-analysis-results.json';
  fs.writeFileSync(outputPath, JSON.stringify(analysisResults, null, 2));
  console.log(`\n✅ Full analysis saved to: ${outputPath}`);

  return analysisResults;
}

/**
 * Main execution
 */
async function main() {
  try {
    const results = await analyzeAllCurrencies();
    
    console.log('\n\n╔══════════════════════════════════════════════════════════════════╗');
    console.log('║                    ✅ ANALYSIS COMPLETE                         ║');
    console.log('╚══════════════════════════════════════════════════════════════════╝');
    
    console.log('\n📝 NEXT STEPS:');
    console.log('1. Review the average margins above');
    console.log('2. Copy the providerMargins code block');
    console.log('3. Update Backend-API/scrapers/wiseComparison.js');
    console.log('4. Redeploy to Vercel\n');

  } catch (error) {
    console.error('\n❌ Analysis failed:', error);
    process.exit(1);
  }
}

// Run analysis
main();

