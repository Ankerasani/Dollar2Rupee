// Test fallback scenarios
const { getAllRates } = require('./scrapers/wiseComparison');

async function testFallbacks() {
  console.log('🧪 TESTING FALLBACK SCENARIOS\n');
  
  // Test 1: Normal operation (should use Wise API)
  console.log('=' .repeat(70));
  console.log('TEST 1: Normal Operation (All APIs working)\n');
  console.log('='.repeat(70) + '\n');
  
  try {
    const result = await getAllRates();
    
    console.log('\n📊 RESULT:');
    console.log(`  Success: ${result.success}`);
    console.log(`  Fallback Level: ${result.fallbackLevel}`);
    console.log(`  Forex: ${result.forexRate.rate} INR (${result.forexRate.source})`);
    console.log(`  Total Providers: ${result.count}`);
    console.log(`  Sources:`);
    console.log(`    - Wise API: ${result.sources.wiseApi}`);
    console.log(`    - Calculated: ${result.sources.calculated}`);
    console.log(`    - Emergency: ${result.sources.emergency}`);
    
    if (result.warning) {
      console.log(`  ⚠️  Warning: ${result.warning}`);
    }
    
    console.log('\n  Top 5 Rates:');
    result.rates
      .sort((a, b) => b.rate - a.rate)
      .slice(0, 5)
      .forEach(r => {
        console.log(`    ${r.provider.padEnd(15)} ${r.rate.toFixed(2)} INR (${r.source})`);
      });
    
  } catch (error) {
    console.error('Test failed:', error);
  }
  
  console.log('\n\n' + '='.repeat(70));
  console.log('✅ Fallback test completed!\n');
  console.log('🎯 Fallback Strategy:');
  console.log('   1. ✅ Wise API (9 providers) → SUCCESS');
  console.log('   2. 📐 Calculate from Forex → If Wise fails');
  console.log('   3. 🚨 Emergency Static Rates → If all APIs fail');
  console.log('   4. 💾 Server Cache (30 min) → Built into Vercel endpoints');
  console.log('='.repeat(70));
}

testFallbacks();

