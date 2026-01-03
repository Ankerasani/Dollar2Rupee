// Local test for Vercel API endpoints
const ratesHandler = require('./api/rates');
const forexHandler = require('./api/forex');

// Mock request/response objects
function createMockReq(query = {}) {
  return {
    method: 'GET',
    query: query
  };
}

function createMockRes() {
  const res = {
    headers: {},
    statusCode: 200,
    body: null
  };
  
  res.setHeader = (key, value) => {
    res.headers[key] = value;
    return res;
  };
  
  res.status = (code) => {
    res.statusCode = code;
    return res;
  };
  
  res.json = (data) => {
    res.body = data;
    return res;
  };
  
  res.end = () => res;
  
  return res;
}

async function testAPIs() {
  console.log('🧪 Testing Vercel API Endpoints\n');
  console.log('='.repeat(70));
  
  // Test 1: Forex API
  console.log('\n📍 TEST 1: /api/forex\n');
  const forexReq = createMockReq();
  const forexRes = createMockRes();
  
  await forexHandler(forexReq, forexRes);
  
  console.log(`Status: ${forexRes.statusCode}`);
  console.log(`Response:`, JSON.stringify(forexRes.body, null, 2));
  
  // Test 2: Rates API
  console.log('\n' + '='.repeat(70));
  console.log('\n📍 TEST 2: /api/rates\n');
  const ratesReq = createMockReq();
  const ratesRes = createMockRes();
  
  await ratesHandler(ratesReq, ratesRes);
  
  console.log(`Status: ${ratesRes.statusCode}`);
  console.log(`Success: ${ratesRes.body.success}`);
  console.log(`Total Rates: ${ratesRes.body.count}`);
  console.log(`Sources: Wise API: ${ratesRes.body.sources.wiseApi}, Calculated: ${ratesRes.body.sources.calculated}`);
  console.log(`\nProvider Rates (Top 5):`);
  
  ratesRes.body.rates
    .sort((a, b) => b.rate - a.rate)
    .slice(0, 5)
    .forEach(rate => {
      const source = rate.source === 'wise-api' ? '(Wise API)' : '(calculated)';
      console.log(`  ${rate.provider.padEnd(15)} ${rate.rate} INR ${source}`);
    });
  
  console.log('\n' + '='.repeat(70));
  console.log('\n✅ All API tests completed!\n');
}

testAPIs().catch(console.error);

