// Test script to verify REAL data scraping - DIRECT from each provider
const { scrapeAllRates, getForexRate } = require('./scrapers/rateScraper');

console.log('='.repeat(70));
console.log('🧪 TESTING DIRECT PROVIDER SCRAPING - NO AGGREGATORS');
console.log('='.repeat(70));
console.log('');
console.log('Testing each provider website individually...');
console.log('(Aggregators like Monito/CompareRemit are fallback only)');
console.log('');

async function test() {
  try {
    console.log('1️⃣ Testing Forex Rate API...');
    const forex = await getForexRate();
    console.log('✅ Forex Rate:', JSON.stringify(forex, null, 2));
    console.log('');
    
    console.log('2️⃣ Testing DIRECT scraping from each provider...');
    console.log('   (This will take 10-20 seconds)\n');
    
    const result = await scrapeAllRates();
    
    console.log('');
    console.log('='.repeat(70));
    console.log('📊 FINAL RESULTS - DIRECT FROM PROVIDERS');
    console.log('='.repeat(70));
    console.log('');
    console.log(`Success: ${result.success}`);
    console.log(`Forex Rate: ${result.forexRate.rate} INR (Real from Frankfurter API)`);
    console.log(`Providers Scraped Directly: ${result.directScrapingCount || result.count}`);
    console.log(`Total Unique Rates: ${result.count}`);
    console.log('');
    console.log('Individual Provider Rates:');
    console.log('');
    
    // Group by provider
    const providerList = [
      'transferwise', 'xoom', 'remit2india', 'westernunion', 'remitly',
      'instarem', 'ria', 'remitmoney', 'transfast', 'statebank', 'ofx'
    ];
    
    providerList.forEach(provider => {
      const found = result.rates.find(r => r.provider === provider);
      if (found) {
        console.log(`  ✅ ${provider.padEnd(20)} ${found.rate.toFixed(2)} INR`);
      } else {
        console.log(`  ❌ ${provider.padEnd(20)} Failed to scrape`);
      }
    });
    
    console.log('');
    console.log('🎯 Strategy:');
    console.log('  • PRIMARY: Direct scraping from each provider website');
    console.log('  • FALLBACK: Aggregator sites (Monito/CompareRemit) if < 3 succeed');
    console.log('  • NO MOCK DATA: Real scraping only');
    console.log('');
    console.log(`🎉 ${result.count}/11 providers have real data!`);
    console.log('');
    
  } catch (error) {
    console.error('');
    console.error('='.repeat(60));
    console.error('❌ TEST FAILED');
    console.error('='.repeat(60));
    console.error('');
    console.error('Error:', error.message);
    console.error('');
    console.error('This means:');
    console.error('1. No mock/fake data will be returned');
    console.error('2. Scraping may need adjustments for current website structure');
    console.error('3. Check network connectivity');
    console.error('4. Websites may have changed their HTML structure');
    console.error('');
    process.exit(1);
  }
}

test();

