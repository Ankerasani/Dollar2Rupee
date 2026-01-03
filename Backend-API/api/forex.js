// Forex rate endpoint
// Using Wise API (mid-market rate) as primary, Frankfurter as fallback
const { getForexRate } = require('../scrapers/wiseComparison');

// Cache by currency: "USD", "GBP", etc.
const cache = {};
const CACHE_DURATION = 60 * 60 * 1000; // 1 hour (forex changes less frequently)

const SUPPORTED_CURRENCIES = ['USD', 'GBP', 'EUR', 'CAD', 'AUD', 'SGD'];

/**
 * Forex Rate API Endpoint
 * GET /api/forex?currency=USD
 * 
 * Returns the mid-market rate to INR for specified currency
 * Primary source: Wise API (true mid-market rate)
 * Fallback: Frankfurter API
 */
module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }
  
  try {
    const now = Date.now();
    const forceRefresh = req.query.refresh === 'true';
    const sourceCurrency = (req.query.currency || 'USD').toUpperCase();
    
    // Validate currency
    if (!SUPPORTED_CURRENCIES.includes(sourceCurrency)) {
      return res.status(400).json({
        success: false,
        error: `Currency not supported: ${sourceCurrency}`,
        supported: SUPPORTED_CURRENCIES
      });
    }
    
    if (!forceRefresh && cache[sourceCurrency] && (now - cache[sourceCurrency].timestamp < CACHE_DURATION)) {
      return res.status(200).json({
        success: true,
        ...cache[sourceCurrency].data,
        cached: true
      });
    }
    
    const forexData = await getForexRate(sourceCurrency);
    
    if (!forexData) {
      throw new Error(`Failed to fetch forex rate for ${sourceCurrency}`);
    }
    
    cache[sourceCurrency] = {
      data: forexData,
      timestamp: now
    };
    
    return res.status(200).json({
      success: true,
      ...forexData,
      cached: false
    });
    
  } catch (error) {
    console.error('Forex API Error:', error);
    
    const sourceCurrency = (req.query.currency || 'USD').toUpperCase();
    
    if (cache[sourceCurrency]) {
      return res.status(200).json({
        success: true,
        ...cache[sourceCurrency].data,
        cached: true,
        warning: 'Serving stale cache'
      });
    }
    
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch forex rate'
    });
  }
};

