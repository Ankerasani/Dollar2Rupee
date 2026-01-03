// API Routes for Vercel Serverless Functions
// Using Wise Comparison API for real-time rates
const { getAllRates } = require('../scrapers/wiseComparison');

// In-memory cache (for simple deployment)
// Cache by currency pair: "USD-INR", "GBP-PHP", etc.
const cache = {};
const CACHE_DURATION = 30 * 60 * 1000; // 30 minutes

// Supported currencies
const SUPPORTED_SOURCE_CURRENCIES = ['USD', 'GBP', 'EUR', 'CAD', 'AUD', 'SGD'];
const SUPPORTED_TARGET_CURRENCIES = ['INR', 'PHP', 'MXN', 'PKR', 'BDT', 'NGN', 'VND', 'EGP', 'IDR', 'COP'];

/**
 * Main API endpoint - Provider Remittance Rates
 * GET /api/rates?currency=USD&target=INR
 * 
 * Data source: Wise Comparison API (real-time rates from multiple providers)
 */
module.exports = async (req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
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
    const targetCurrency = (req.query.target || 'INR').toUpperCase();
    
    // Validate source currency
    if (!SUPPORTED_SOURCE_CURRENCIES.includes(sourceCurrency)) {
      return res.status(400).json({
        success: false,
        error: `Source currency not supported: ${sourceCurrency}`,
        supportedSource: SUPPORTED_SOURCE_CURRENCIES,
        supportedTarget: SUPPORTED_TARGET_CURRENCIES
      });
    }
    
    // Validate target currency
    if (!SUPPORTED_TARGET_CURRENCIES.includes(targetCurrency)) {
      return res.status(400).json({
        success: false,
        error: `Target currency not supported: ${targetCurrency}`,
        supportedSource: SUPPORTED_SOURCE_CURRENCIES,
        supportedTarget: SUPPORTED_TARGET_CURRENCIES
      });
    }
    
    const cacheKey = `${sourceCurrency}-${targetCurrency}`;
    
    // Check if cache is valid
    if (!forceRefresh && cache[cacheKey] && (now - cache[cacheKey].timestamp < CACHE_DURATION)) {
      console.log(`Serving cached rates for ${cacheKey}`);
      return res.status(200).json({
        ...cache[cacheKey].data,
        cached: true,
        cacheAge: Math.floor((now - cache[cacheKey].timestamp) / 1000) + ' seconds'
      });
    }
    
    // Fetch fresh data from Wise Comparison API
    console.log(`Fetching fresh rates for ${cacheKey}...`);
    const data = await getAllRates(sourceCurrency, targetCurrency);
    
    if (!data.success) {
      throw new Error(`Failed to fetch rates for ${sourceCurrency} → ${targetCurrency}`);
    }
    
    // Update cache
    cache[cacheKey] = {
      data: data,
      timestamp: now
    };
    
    return res.status(200).json({
      ...data,
      cached: false
    });
    
  } catch (error) {
    console.error('API Error:', error);
    
    const sourceCurrency = (req.query.currency || 'USD').toUpperCase();
    const targetCurrency = (req.query.target || 'INR').toUpperCase();
    const cacheKey = `${sourceCurrency}-${targetCurrency}`;
    
    // Return cached data if available, even if expired
    if (cache[cacheKey]) {
      return res.status(200).json({
        ...cache[cacheKey].data,
        cached: true,
        warning: 'Serving stale cache due to API error'
      });
    }
    
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch rates',
      message: error.message
    });
  }
};

