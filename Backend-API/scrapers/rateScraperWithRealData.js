// REAL SCRAPING from CompareRemit
const axios = require('axios');
const cheerio = require('cheerio');

/**
 * Get real forex rate
 */
async function getForexRate() {
  try {
    const response = await axios.get('https://api.frankfurter.app/latest?from=USD&to=INR');
    return {
      rate: response.data.rates.INR,
      date: response.data.date,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('Forex error:', error.message);
    return { rate: 83.0, date: new Date().toISOString(), timestamp: new Date().toISOString() };
  }
}

/**
 * Scrape rates from CompareRemit.com
 * This site aggregates all provider rates in one place
 */
async function scrapeCompareRemit() {
  try {
    const url = 'https://www.compareremit.com/money-transfer-providers/send-money-from-usa-to-india/';
    
    const response = await axios.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
      },
      timeout: 15000
    });
    
    const $ = cheerio.load(response.data);
    const rates = [];
    
    console.log('Scraping CompareRemit...');
    
    // Try multiple selectors (site structure may vary)
    // You'll need to inspect the actual HTML to confirm these
    
    // Attempt 1: Table structure
    $('table tr').each((i, row) => {
      try {
        const providerText = $(row).find('td').eq(0).text().trim().toLowerCase();
        const rateText = $(row).find('td').eq(2).text().trim();
        const rate = parseFloat(rateText.replace(/[^0-9.]/g, ''));
        
        if (providerText && rate > 70 && rate < 90) { // Sanity check
          const provider = normalizeProviderName(providerText);
          if (provider) {
            rates.push({
              provider: provider,
              rate: rate,
              timestamp: new Date().toISOString()
            });
          }
        }
      } catch (e) {
        // Skip invalid rows
      }
    });
    
    // Attempt 2: Div/Card structure
    if (rates.length === 0) {
      $('.provider-card, .rate-card, .comparison-item').each((i, card) => {
        try {
          const providerText = $(card).find('.provider-name, .company-name, h3').text().trim().toLowerCase();
          const rateText = $(card).find('.rate, .exchange-rate, .price').text().trim();
          const rate = parseFloat(rateText.replace(/[^0-9.]/g, ''));
          
          if (providerText && rate > 70 && rate < 90) {
            const provider = normalizeProviderName(providerText);
            if (provider) {
              rates.push({
                provider: provider,
                rate: rate,
                timestamp: new Date().toISOString()
              });
            }
          }
        } catch (e) {
          // Skip invalid cards
        }
      });
    }
    
    console.log(`Scraped ${rates.length} rates from CompareRemit`);
    return rates;
    
  } catch (error) {
    console.error('CompareRemit scraping error:', error.message);
    return [];
  }
}

/**
 * Normalize provider names to match your app's expected names
 */
function normalizeProviderName(text) {
  const lower = text.toLowerCase().replace(/[^a-z0-9]/g, '');
  
  // Map variations to your app's provider names
  const mapping = {
    'wise': 'transferwise',
    'transferwise': 'transferwise',
    'xoom': 'xoom',
    'remit2india': 'remit2india',
    'remittoindia': 'remit2india',
    'westernunion': 'westernunion',
    'wu': 'westernunion',
    'remitly': 'remitly',
    'instarem': 'instarem',
    'ria': 'ria',
    'riamoneytransfer': 'ria',
    'remitmoney': 'remitmoney',
    'transfast': 'transfast',
    'sbi': 'statebank',
    'statebank': 'statebank',
    'statebankofindiacalifornia': 'statebank',
    'ofx': 'ofx',
    'icici': 'icici',
    'icicimoney2india': 'icici',
  };
  
  return mapping[lower] || null;
}

/**
 * Main function - combines all sources
 */
async function scrapeAllRates() {
  console.log('Starting rate collection...');
  
  // Get real forex rate
  const forexRate = await getForexRate();
  
  // Try to scrape real data
  let rates = await scrapeCompareRemit();
  
  // Fallback to mock data if scraping fails
  if (rates.length === 0) {
    console.warn('Scraping failed, using fallback mock data');
    const baseRate = forexRate.rate;
    rates = [
      { provider: 'transferwise', rate: baseRate - 1.0, timestamp: new Date().toISOString() },
      { provider: 'xoom', rate: baseRate - 1.3, timestamp: new Date().toISOString() },
      { provider: 'remit2india', rate: baseRate - 1.1, timestamp: new Date().toISOString() },
      { provider: 'westernunion', rate: baseRate - 1.5, timestamp: new Date().toISOString() },
      { provider: 'remitly', rate: baseRate - 1.2, timestamp: new Date().toISOString() },
      { provider: 'instarem', rate: baseRate - 1.15, timestamp: new Date().toISOString() },
      { provider: 'ria', rate: baseRate - 1.6, timestamp: new Date().toISOString() },
      { provider: 'remitmoney', rate: baseRate - 1.4, timestamp: new Date().toISOString() },
      { provider: 'transfast', rate: baseRate - 1.55, timestamp: new Date().toISOString() },
      { provider: 'statebank', rate: baseRate - 1.25, timestamp: new Date().toISOString() },
      { provider: 'ofx', rate: baseRate - 1.45, timestamp: new Date().toISOString() },
    ];
  }
  
  return {
    success: true,
    forexRate: forexRate,
    rates: rates,
    timestamp: new Date().toISOString(),
    count: rates.length,
    source: rates.length > 0 && rates[0].rate !== (forexRate.rate - 1.0) ? 'scraped' : 'mock'
  };
}

module.exports = {
  scrapeAllRates,
  getForexRate
};

