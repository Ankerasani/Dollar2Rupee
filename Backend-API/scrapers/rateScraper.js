// HYBRID: Real scraped data + Calculated rates for missing providers
// Clearly marks which rates are real vs calculated

const axios = require('axios');
const cheerio = require('cheerio');

/**
 * Get REAL forex rate
 */
async function getForexRate() {
  try {
    const response = await axios.get('https://api.frankfurter.app/latest?from=USD&to=INR', {
      timeout: 10000
    });
    return {
      rate: response.data.rates.INR,
      date: response.data.date,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('Forex API error:', error.message);
    throw new Error('Failed to fetch forex rate');
  }
}

/**
 * Scrape Wise
 */
async function scrapeWise() {
  try {
    console.log('Scraping Wise...');
    
    const response = await axios.get('https://wise.com/us/currency-converter/usd-to-inr-rate', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 15000
    });
    
    const $ = cheerio.load(response.data);
    let rate = null;
    
    $('script').each((i, elem) => {
      const text = $(elem).html();
      if (text && text.includes('rate')) {
        const match = text.match(/"rate":\s*([0-9.]+)/);
        if (match) {
          const potentialRate = parseFloat(match[1]);
          if (potentialRate > 70 && potentialRate < 100) {
            rate = potentialRate;
          }
        }
      }
    });
    
    if (rate) {
      console.log(`✅ Wise: ${rate.toFixed(2)} (REAL SCRAPED)`);
      return {
        provider: 'transferwise',
        rate: parseFloat(rate.toFixed(2)),
        timestamp: new Date().toISOString(),
        source: 'scraped'
      };
    }
    
    throw new Error('Rate not found');
  } catch (error) {
    console.error(`❌ Wise: ${error.message}`);
    return null;
  }
}

/**
 * Scrape Xoom
 */
async function scrapeXoom() {
  try {
    console.log('Scraping Xoom...');
    
    const response = await axios.get('https://www.xoom.com/india/send-money', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 15000
    });
    
    const $ = cheerio.load(response.data);
    let rate = null;
    
    $('script').each((i, elem) => {
      const text = $(elem).html();
      if (text && text.includes('exchangeRate')) {
        const match = text.match(/exchangeRate["\s:]+([0-9.]+)/);
        if (match) {
          rate = parseFloat(match[1]);
        }
      }
    });
    
    if (rate && rate > 70 && rate < 100) {
      console.log(`✅ Xoom: ${rate.toFixed(2)} (REAL SCRAPED)`);
      return {
        provider: 'xoom',
        rate: parseFloat(rate.toFixed(2)),
        timestamp: new Date().toISOString(),
        source: 'scraped'
      };
    }
    
    throw new Error('Rate not found');
  } catch (error) {
    console.error(`❌ Xoom: ${error.message}`);
    return null;
  }
}

/**
 * Scrape Remit2India
 */
async function scrapeRemit2India() {
  try {
    console.log('Scraping Remit2India...');
    
    const response = await axios.get('https://www.remit2india.com/', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 15000
    });
    
    const $ = cheerio.load(response.data);
    let rate = null;
    
    $('script').each((i, elem) => {
      const text = $(elem).html();
      if (text && text.includes('rate')) {
        const match = text.match(/rate["\s:]+([0-9.]+)/);
        if (match) {
          const potentialRate = parseFloat(match[1]);
          if (potentialRate > 70 && potentialRate < 100) {
            rate = potentialRate;
          }
        }
      }
    });
    
    if (rate) {
      console.log(`✅ Remit2India: ${rate.toFixed(2)} (REAL SCRAPED)`);
      return {
        provider: 'remit2india',
        rate: parseFloat(rate.toFixed(2)),
        timestamp: new Date().toISOString(),
        source: 'scraped'
      };
    }
    
    throw new Error('Rate not found');
  } catch (error) {
    console.error(`❌ Remit2India: ${error.message}`);
    return null;
  }
}

/**
 * Scrape Western Union
 */
async function scrapeWesternUnion() {
  try {
    console.log('Scraping Western Union...');
    
    const response = await axios.get('https://www.westernunion.com/us/en/web/send-money/start', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 15000
    });
    
    const $ = cheerio.load(response.data);
    let rate = null;
    
    $('script').each((i, elem) => {
      const text = $(elem).html();
      if (text && text.includes('fxRate')) {
        const match = text.match(/fxRate["\s:]+([0-9.]+)/);
        if (match) {
          const potentialRate = parseFloat(match[1]);
          if (potentialRate > 70 && potentialRate < 100) {
            rate = potentialRate;
          }
        }
      }
    });
    
    if (rate) {
      console.log(`✅ Western Union: ${rate.toFixed(2)} (REAL SCRAPED)`);
      return {
        provider: 'westernunion',
        rate: parseFloat(rate.toFixed(2)),
        timestamp: new Date().toISOString(),
        source: 'scraped'
      };
    }
    
    throw new Error('Rate not found');
  } catch (error) {
    console.error(`❌ Western Union: ${error.message}`);
    return null;
  }
}

/**
 * Scrape Remitly
 */
async function scrapeRemitly() {
  try {
    console.log('Scraping Remitly...');
    
    const response = await axios.get('https://www.remitly.com/us/en/', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 15000
    });
    
    const $ = cheerio.load(response.data);
    let rate = null;
    
    $('script').each((i, elem) => {
      const text = $(elem).html();
      if (text && text.includes('exchangeRate')) {
        const match = text.match(/exchangeRate["\s:]+([0-9.]+)/);
        if (match) {
          const potentialRate = parseFloat(match[1]);
          if (potentialRate > 70 && potentialRate < 100) {
            rate = potentialRate;
          }
        }
      }
    });
    
    if (rate) {
      console.log(`✅ Remitly: ${rate.toFixed(2)} (REAL SCRAPED)`);
      return {
        provider: 'remitly',
        rate: parseFloat(rate.toFixed(2)),
        timestamp: new Date().toISOString(),
        source: 'scraped'
      };
    }
    
    throw new Error('Rate not found');
  } catch (error) {
    console.error(`❌ Remitly: ${error.message}`);
    return null;
  }
}

/**
 * Scrape InstareM
 */
async function scrapeInstarem() {
  try {
    console.log('Scraping InstareM...');
    
    const response = await axios.get('https://www.instarem.com/en-us/', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 15000
    });
    
    const $ = cheerio.load(response.data);
    let rate = null;
    
    $('script').each((i, elem) => {
      const text = $(elem).html();
      if (text && text.includes('rate')) {
        const match = text.match(/rate["\s:]+([0-9.]+)/);
        if (match) {
          const potentialRate = parseFloat(match[1]);
          if (potentialRate > 70 && potentialRate < 100) {
            rate = potentialRate;
          }
        }
      }
    });
    
    if (rate) {
      console.log(`✅ InstareM: ${rate.toFixed(2)} (REAL SCRAPED)`);
      return {
        provider: 'instarem',
        rate: parseFloat(rate.toFixed(2)),
        timestamp: new Date().toISOString(),
        source: 'scraped'
      };
    }
    
    throw new Error('Rate not found');
  } catch (error) {
    console.error(`❌ InstareM: ${error.message}`);
    return null;
  }
}

/**
 * Scrape Ria
 */
async function scrapeRia() {
  try {
    console.log('Scraping Ria...');
    
    const response = await axios.get('https://www.riamoneytransfer.com/en-us/home', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 15000
    });
    
    const $ = cheerio.load(response.data);
    let rate = null;
    
    $('script').each((i, elem) => {
      const text = $(elem).html();
      if (text && text.includes('exchangeRate')) {
        const match = text.match(/exchangeRate["\s:]+([0-9.]+)/);
        if (match) {
          const potentialRate = parseFloat(match[1]);
          if (potentialRate > 70 && potentialRate < 100) {
            rate = potentialRate;
          }
        }
      }
    });
    
    if (rate) {
      console.log(`✅ Ria: ${rate.toFixed(2)} (REAL SCRAPED)`);
      return {
        provider: 'ria',
        rate: parseFloat(rate.toFixed(2)),
        timestamp: new Date().toISOString(),
        source: 'scraped'
      };
    }
    
    throw new Error('Rate not found');
  } catch (error) {
    console.error(`❌ Ria: ${error.message}`);
    return null;
  }
}

/**
 * Scrape RemitMoney
 */
async function scrapeRemitMoney() {
  try {
    console.log('Scraping RemitMoney...');
    
    const response = await axios.get('https://www.remitmoney.com/', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 15000
    });
    
    const $ = cheerio.load(response.data);
    let rate = null;
    
    $('script').each((i, elem) => {
      const text = $(elem).html();
      if (text && text.includes('rate')) {
        const match = text.match(/rate["\s:]+([0-9.]+)/);
        if (match) {
          const potentialRate = parseFloat(match[1]);
          if (potentialRate > 70 && potentialRate < 100) {
            rate = potentialRate;
          }
        }
      }
    });
    
    if (rate) {
      console.log(`✅ RemitMoney: ${rate.toFixed(2)} (REAL SCRAPED)`);
      return {
        provider: 'remitmoney',
        rate: parseFloat(rate.toFixed(2)),
        timestamp: new Date().toISOString(),
        source: 'scraped'
      };
    }
    
    throw new Error('Rate not found');
  } catch (error) {
    console.error(`❌ RemitMoney: ${error.message}`);
    return null;
  }
}

/**
 * Scrape Transfast
 */
async function scrapeTransfast() {
  try {
    console.log('Scraping Transfast...');
    
    const response = await axios.get('https://www.transfast.com/', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 15000
    });
    
    const $ = cheerio.load(response.data);
    let rate = null;
    
    $('script').each((i, elem) => {
      const text = $(elem).html();
      if (text && text.includes('rate')) {
        const match = text.match(/rate["\s:]+([0-9.]+)/);
        if (match) {
          const potentialRate = parseFloat(match[1]);
          if (potentialRate > 70 && potentialRate < 100) {
            rate = potentialRate;
          }
        }
      }
    });
    
    if (rate) {
      console.log(`✅ Transfast: ${rate.toFixed(2)} (REAL SCRAPED)`);
      return {
        provider: 'transfast',
        rate: parseFloat(rate.toFixed(2)),
        timestamp: new Date().toISOString(),
        source: 'scraped'
      };
    }
    
    throw new Error('Rate not found');
  } catch (error) {
    console.error(`❌ Transfast: ${error.message}`);
    return null;
  }
}

/**
 * Scrape SBI
 */
async function scrapeSBI() {
  try {
    console.log('Scraping SBI...');
    
    const response = await axios.get('https://www.sbremit.com/', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 15000
    });
    
    const $ = cheerio.load(response.data);
    let rate = null;
    
    $('script').each((i, elem) => {
      const text = $(elem).html();
      if (text && text.includes('rate')) {
        const match = text.match(/rate["\s:]+([0-9.]+)/);
        if (match) {
          const potentialRate = parseFloat(match[1]);
          if (potentialRate > 70 && potentialRate < 100) {
            rate = potentialRate;
          }
        }
      }
    });
    
    if (rate) {
      console.log(`✅ SBI: ${rate.toFixed(2)} (REAL SCRAPED)`);
      return {
        provider: 'statebank',
        rate: parseFloat(rate.toFixed(2)),
        timestamp: new Date().toISOString(),
        source: 'scraped'
      };
    }
    
    throw new Error('Rate not found');
  } catch (error) {
    console.error(`❌ SBI: ${error.message}`);
    return null;
  }
}

/**
 * Scrape OFX
 */
async function scrapeOFX() {
  try {
    console.log('Scraping OFX...');
    
    const response = await axios.get('https://www.ofx.com/en-us/', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 15000
    });
    
    const $ = cheerio.load(response.data);
    let rate = null;
    
    $('script').each((i, elem) => {
      const text = $(elem).html();
      if (text && text.includes('USD') && text.includes('INR')) {
        const match = text.match(/INR["\s:]+([0-9.]+)/);
        if (match) {
          const potentialRate = parseFloat(match[1]);
          if (potentialRate > 70 && potentialRate < 100) {
            rate = potentialRate;
          }
        }
      }
    });
    
    if (rate) {
      console.log(`✅ OFX: ${rate.toFixed(2)} (REAL SCRAPED)`);
      return {
        provider: 'ofx',
        rate: parseFloat(rate.toFixed(2)),
        timestamp: new Date().toISOString(),
        source: 'scraped'
      };
    }
    
    throw new Error('Rate not found');
  } catch (error) {
    console.error(`❌ OFX: ${error.message}`);
    return null;
  }
}

/**
 * Scrape from Monito aggregator
 */
async function scrapeFromMonito() {
  try {
    console.log('Scraping Monito aggregator...');
    
    const response = await axios.get('https://www.monito.com/en/compare/send-money-from-united-states-to-india/usd/inr', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 20000
    });
    
    const $ = cheerio.load(response.data);
    const rates = [];
    
    // Provider name mappings
    const providerMap = {
      'wise': 'transferwise',
      'transferwise': 'transferwise',
      'xoom': 'xoom',
      'remit2india': 'remit2india',
      'western union': 'westernunion',
      'westernunion': 'westernunion',
      'remitly': 'remitly',
      'instarem': 'instarem',
      'ria': 'ria',
      'remitmoney': 'remitmoney',
      'transfast': 'transfast',
      'sbi': 'statebank',
      'state bank': 'statebank',
      'ofx': 'ofx',
      'moneygram': 'moneygram',
      'worldremit': 'worldremit'
    };
    
    // Try to find rate information in JSON data
    $('script[type="application/json"]').each((i, elem) => {
      try {
        const data = JSON.parse($(elem).html());
        if (data && typeof data === 'object') {
          JSON.stringify(data).match(/"rate":\s*([0-9.]+)|"exchangeRate":\s*([0-9.]+)/g);
        }
      } catch (e) {}
    });
    
    // Parse table or list items with provider data
    $('.provider, .comparison-row, [data-provider]').each((i, elem) => {
      const text = $(elem).text().toLowerCase();
      const providerName = Object.keys(providerMap).find(name => text.includes(name));
      
      if (providerName) {
        const rateMatch = $(elem).text().match(/([0-9]{2}\.[0-9]{2})/);
        if (rateMatch) {
          const rate = parseFloat(rateMatch[1]);
          if (rate > 70 && rate < 100) {
            rates.push({
              provider: providerMap[providerName],
              rate: rate,
              timestamp: new Date().toISOString(),
              source: 'monito'
            });
          }
        }
      }
    });
    
    if (rates.length > 0) {
      console.log(`✅ Monito: Found ${rates.length} provider rates`);
      return rates;
    }
    
    throw new Error('No rates found');
  } catch (error) {
    console.error(`❌ Monito: ${error.message}`);
    return [];
  }
}

/**
 * Scrape from CompareRemit aggregator
 */
async function scrapeFromCompareRemit() {
  try {
    console.log('Scraping CompareRemit aggregator...');
    
    const response = await axios.get('https://www.compareremit.com/money-transfer-to-india/', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
      timeout: 20000
    });
    
    const $ = cheerio.load(response.data);
    const rates = [];
    
    // Provider name mappings
    const providerMap = {
      'wise': 'transferwise',
      'transferwise': 'transferwise',
      'xoom': 'xoom',
      'remit2india': 'remit2india',
      'western union': 'westernunion',
      'westernunion': 'westernunion',
      'remitly': 'remitly',
      'instarem': 'instarem',
      'ria': 'ria',
      'remitmoney': 'remitmoney',
      'transfast': 'transfast',
      'sbi': 'statebank',
      'state bank': 'statebank',
      'ofx': 'ofx',
      'moneygram': 'moneygram',
      'worldremit': 'worldremit'
    };
    
    // Look for comparison table rows
    $('tr, .comparison-item, .provider-row').each((i, elem) => {
      const text = $(elem).text().toLowerCase();
      const providerName = Object.keys(providerMap).find(name => text.includes(name));
      
      if (providerName) {
        // Look for exchange rate pattern
        const rateMatch = $(elem).text().match(/(?:rate|exchange)[:\s]*([0-9]{2}\.[0-9]{2})|([0-9]{2}\.[0-9]{2})\s*(?:INR|₹)/i);
        if (rateMatch) {
          const rate = parseFloat(rateMatch[1] || rateMatch[2]);
          if (rate > 70 && rate < 100) {
            rates.push({
              provider: providerMap[providerName],
              rate: rate,
              timestamp: new Date().toISOString(),
              source: 'compareremit'
            });
          }
        }
      }
    });
    
    if (rates.length > 0) {
      console.log(`✅ CompareRemit: Found ${rates.length} provider rates`);
      return rates;
    }
    
    throw new Error('No rates found');
  } catch (error) {
    console.error(`❌ CompareRemit: ${error.message}`);
    return [];
  }
}

/**
 * Calculate rates for providers that couldn't be scraped
 * Based on FOREX RATE (from Frankfurter API) with typical remittance margins
 */
function calculateMissingRates(forexRate, missingProviders) {
  console.log(`\n📐 Calculating rates for ${missingProviders.length} providers based on FOREX rate...`);
  console.log(`   Base Forex Rate: ${forexRate} INR\n`);
  
  // Margins from forex rate (remittance providers typically offer less than forex rate)
  const providerMargins = {
    'transferwise': -3.0,    // Wise: typically 3 INR below forex
    'xoom': -3.5,            // Xoom: typically 3.5 INR below forex
    'remit2india': -2.8,     // Remit2India: typically 2.8 INR below forex
    'westernunion': -4.2,    // Western Union: typically 4.2 INR below forex
    'remitly': -3.3,         // Remitly: typically 3.3 INR below forex
    'instarem': -3.4,        // InstareM: typically 3.4 INR below forex
    'ria': -4.5,             // Ria: typically 4.5 INR below forex
    'remitmoney': -3.8,      // RemitMoney: typically 3.8 INR below forex
    'transfast': -4.0,       // Transfast: typically 4.0 INR below forex
    'statebank': -3.5,       // SBI: typically 3.5 INR below forex
    'ofx': -3.9              // OFX: typically 3.9 INR below forex
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
        source: 'calculated'
      });
      console.log(`  • ${provider.padEnd(15)} ${rate.toFixed(2)} INR (Forex ${forexRate} + ${providerMargins[provider]})`);
    }
  });
  
  return calculated;
}

/**
 * Main scraper - Try 3 approaches and compare
 */
async function scrapeAllRates() {
  console.log('🔍 THREE-STEP APPROACH: Direct Scraping → Aggregators → Calculated\n');
  console.log('='.repeat(70));
  
  try {
    const forexRate = await getForexRate();
    console.log(`✅ Forex: ${forexRate.rate} (REAL API)\n`);
    
    // STEP 1: Try direct scraping from each provider
    console.log('📍 STEP 1: Direct scraping from provider websites...\n');
    const directResults = await Promise.allSettled([
      scrapeWise(),
      scrapeXoom(),
      scrapeRemit2India(),
      scrapeWesternUnion(),
      scrapeRemitly(),
      scrapeInstarem(),
      scrapeRia(),
      scrapeRemitMoney(),
      scrapeTransfast(),
      scrapeSBI(),
      scrapeOFX()
    ]);
    
    const directScraped = directResults
      .filter(r => r.status === 'fulfilled' && r.value !== null)
      .map(r => r.value);
    
    console.log(`\n📊 Direct scraping result: ${directScraped.length}/11 providers\n`);
    
    // STEP 2: Try aggregator sites (Monito & CompareRemit)
    console.log('='.repeat(70));
    console.log('📍 STEP 2: Scraping from aggregator sites...\n');
    
    const [monitoRates, compareRemitRates] = await Promise.all([
      scrapeFromMonito(),
      scrapeFromCompareRemit()
    ]);
    
    console.log(`\n📊 Aggregator scraping result:`);
    console.log(`   - Monito: ${monitoRates.length} providers`);
    console.log(`   - CompareRemit: ${compareRemitRates.length} providers\n`);
    
    // Merge aggregator rates (prefer Monito, then CompareRemit)
    const aggregatorRates = {};
    [...compareRemitRates, ...monitoRates].forEach(rate => {
      aggregatorRates[rate.provider] = rate;
    });
    
    // STEP 3: Calculate missing rates
    console.log('='.repeat(70));
    console.log('📍 STEP 3: Calculating rates for remaining providers...\n');
    
    const allProviders = ['transferwise', 'xoom', 'remit2india', 'westernunion', 'remitly', 
                          'instarem', 'ria', 'remitmoney', 'transfast', 'statebank', 'ofx'];
    
    const directProviders = directScraped.map(r => r.provider);
    const aggregatorProviders = Object.keys(aggregatorRates);
    const coveredProviders = [...new Set([...directProviders, ...aggregatorProviders])];
    const missingProviders = allProviders.filter(p => !coveredProviders.includes(p));
    
    let calculatedRates = [];
    
    if (missingProviders.length > 0) {
      calculatedRates = calculateMissingRates(forexRate.rate, missingProviders);
    }
    
    // Combine all rates (Priority: Direct > Aggregator > Calculated)
    const finalRates = {};
    
    // Add calculated rates first (lowest priority)
    calculatedRates.forEach(rate => {
      finalRates[rate.provider] = rate;
    });
    
    // Add aggregator rates (medium priority)
    Object.values(aggregatorRates).forEach(rate => {
      finalRates[rate.provider] = rate;
    });
    
    // Add direct scraped rates (highest priority)
    directScraped.forEach(rate => {
      finalRates[rate.provider] = rate;
    });
    
    const allRates = Object.values(finalRates);
    
    // COMPARISON REPORT
    console.log('\n' + '='.repeat(70));
    console.log('📊 COMPARISON REPORT: Direct vs Aggregators vs Calculated\n');
    
    console.log('Provider          | Direct    | Aggregator | Calculated | Final Used');
    console.log('-'.repeat(70));
    
    allProviders.forEach(provider => {
      const direct = directScraped.find(r => r.provider === provider);
      const aggregator = aggregatorRates[provider];
      const calculated = calculatedRates.find(r => r.provider === provider);
      const final = finalRates[provider];
      
      const directStr = direct ? `${direct.rate.toFixed(2)}` : '  -   ';
      const aggStr = aggregator ? `${aggregator.rate.toFixed(2)}` : '  -   ';
      const calcStr = calculated ? `${calculated.rate.toFixed(2)}` : '  -   ';
      const finalStr = final ? `${final.rate.toFixed(2)} (${final.source})` : '  -   ';
      
      console.log(`${provider.padEnd(17)} | ${directStr}   | ${aggStr}     | ${calcStr}     | ${finalStr}`);
      
      // Show difference if multiple sources exist
      if (direct && aggregator) {
        const diff = Math.abs(direct.rate - aggregator.rate);
        if (diff > 0.10) {
          console.log(`                    ⚠️  Difference: ${diff.toFixed(2)} INR`);
        }
      }
      if (direct && calculated) {
        const diff = Math.abs(direct.rate - calculated.rate);
        if (diff > 0.10) {
          console.log(`                    ⚠️  Calc diff: ${diff.toFixed(2)} INR`);
        }
      }
    });
    
    console.log('\n' + '='.repeat(70));
    console.log('✅ FINAL SUMMARY:\n');
    console.log(`   Total rates: ${allRates.length}`);
    console.log(`   - Direct scraped: ${directScraped.length}`);
    console.log(`   - From aggregators: ${Object.keys(aggregatorRates).length - directProviders.filter(p => aggregatorProviders.includes(p)).length}`);
    console.log(`   - Calculated: ${calculatedRates.filter(r => !directProviders.includes(r.provider) && !aggregatorProviders.includes(r.provider)).length}\n`);
    
    return {
      success: true,
      forexRate: forexRate,
      rates: allRates,
      timestamp: new Date().toISOString(),
      count: allRates.length,
      sources: {
        direct: directScraped.length,
        aggregators: Object.keys(aggregatorRates).length,
        calculated: calculatedRates.length
      },
      comparison: {
        direct: directScraped,
        aggregators: Object.values(aggregatorRates),
        calculated: calculatedRates
      }
    };
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  }
}

module.exports = {
  scrapeAllRates,
  getForexRate
};
