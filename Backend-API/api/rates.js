// API Routes for Vercel Serverless Functions
// Using Wise Comparison API for real-time rates
const { getAllRates } = require('../scrapers/wiseComparison');

// In-memory cache (for simple deployment)
// For production, use Redis or a database
let cachedRates = null;
let lastUpdate = null;
const CACHE_DURATION = 30 * 60 * 1000; // 30 minutes

/**
 * Main API endpoint - Provider Remittance Rates
 * GET /api/rates
 * 
 * Data source: Wise Comparison API (real-time rates from 9+ providers)
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
    
    // Check if cache is valid
    if (!forceRefresh && cachedRates && lastUpdate && (now - lastUpdate < CACHE_DURATION)) {
      console.log('Serving cached rates');
      return res.status(200).json({
        ...cachedRates,
        cached: true,
        cacheAge: Math.floor((now - lastUpdate) / 1000) + ' seconds'
      });
    }
    
    // Fetch fresh data from Wise Comparison API
    console.log('Fetching fresh rates from Wise API...');
    const data = await getAllRates();
    
    if (!data.success) {
      throw new Error('Failed to fetch rates from Wise API');
    }
    
    // Update cache
    cachedRates = data;
    lastUpdate = now;
    
    return res.status(200).json({
      ...data,
      cached: false
    });
    
  } catch (error) {
    console.error('API Error:', error);
    
    // Return cached data if available, even if expired
    if (cachedRates) {
      return res.status(200).json({
        ...cachedRates,
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

