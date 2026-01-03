const { getAllRates } = require('./scrapers/wiseComparison');

async function test() {
  console.log('Testing Wise Comparison API scraper...\n');
  
  try {
    const result = await getAllRates();
    
    console.log('\n' + '='.repeat(70));
    console.log('📊 FINAL RESULTS\n');
    console.log('='.repeat(70));
    console.log(`Success: ${result.success}`);
    console.log(`Forex Rate: ${result.forexRate.rate} INR (${result.forexRate.source})`);
    console.log(`Total Providers: ${result.count}`);
    console.log(`- Wise API: ${result.sources.wiseApi}`);
    console.log(`- Calculated: ${result.sources.calculated}\n`);
    
    console.log('Individual Provider Rates:\n');
    
    result.rates.sort((a, b) => b.rate - a.rate).forEach(rate => {
      const sourceLabel = rate.source === 'wise-api' ? '(WISE API)' : '(calculated)';
      const feeLabel = rate.fee !== undefined ? ` [Fee: $${rate.fee}]` : '';
      console.log(`  ${rate.provider.padEnd(15)} ${rate.rate.toFixed(2)} INR ${sourceLabel}${feeLabel}`);
    });
    
    console.log('\n' + '='.repeat(70));
    
  } catch (error) {
    console.error('Test failed:', error);
  }
}

test();

