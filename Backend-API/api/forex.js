// Forex rate endpoint
// Using Wise API (mid-market rate) as primary, Frankfurter as fallback
const { getForexRate } = require('../scrapers/wiseComparison');

let cachedForex = null;
let lastUpdate = null;
const CACHE_DURATION = 60 * 60 * 1000; // 1 hour (forex changes less frequently)

/**
 * Forex Rate API Endpoint
 * GET /api/forex
 * 
 * Returns the mid-market USD to INR exchange rate
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
    
    if (!forceRefresh && cachedForex && lastUpdate && (now - lastUpdate < CACHE_DURATION)) {
      return res.status(200).json({
        success: true,
        ...cachedForex,
        cached: true
      });
    }
    
    const forexData = await getForexRate();
    
    if (!forexData) {
      throw new Error('Failed to fetch forex rate');
    }
    
    cachedForex = forexData;
    lastUpdate = now;
    
    return res.status(200).json({
      success: true,
      ...forexData,
      cached: false
    });
    
  } catch (error) {
    console.error('Forex API Error:', error);
    
    if (cachedForex) {
      return res.status(200).json({
        success: true,
        ...cachedForex,
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

