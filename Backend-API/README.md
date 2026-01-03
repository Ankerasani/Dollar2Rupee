# Dollar2Rupee Backend API

Real-time exchange rate API for the Dollar2Rupee iOS app.

## 🚀 Live API

**Base URL**: https://dollar2rupee-api.vercel.app

### Endpoints
- `GET /api/rates?currency=USD` - Get remittance rates for USD → INR
- `GET /api/rates?currency=GBP` - Get remittance rates for GBP → INR
- `GET /api/forex?currency=USD` - Get forex rate only
- `GET /api/monitor-margins` - Check margin accuracy (automated monitoring)

### Supported Currencies
USD, GBP, EUR, CAD, AUD, SGD → INR

## 📖 Documentation

- **[MAINTENANCE_GUIDE.md](MAINTENANCE_GUIDE.md)** - How to maintain and update margins (START HERE)
- **[MARGIN_ANALYSIS.md](MARGIN_ANALYSIS.md)** - Technical details on margin calculations

## 🔄 How It Works

1. **Primary**: Fetches real-time rates from Wise Comparison API
2. **Fallback 1**: Calculates from live forex + provider margins
3. **Fallback 2**: Uses server cache (24-hour TTL)
4. **Fallback 3**: Emergency static rates

## 🤖 Automated Monitoring

- Runs daily at midnight UTC (5:30 AM IST)
- Checks if provider margins have changed
- Alerts you when updates are needed
- View logs: https://vercel.com/newsapps-projects-60e3aa11/dollar2rupee-api

## 🛠️ Maintenance

**When margins change** (~10 minutes every 1-2 weeks):
1. Check Vercel logs
2. Run `node analyze-margins.js`
3. Update 2 files with new margins
4. Deploy with `vercel --prod`

See [MAINTENANCE_GUIDE.md](MAINTENANCE_GUIDE.md) for detailed steps.

## 📦 Dependencies

```json
{
  "axios": "^1.6.2",
  "cheerio": "^1.0.0-rc.12"
}
```

## 🧪 Testing

```bash
# Test rates API
curl https://dollar2rupee-api.vercel.app/api/rates?currency=USD

# Test forex API
curl https://dollar2rupee-api.vercel.app/api/forex?currency=USD

# Test monitoring
curl https://dollar2rupee-api.vercel.app/api/monitor-margins

# Run margin analysis locally
node analyze-margins.js
```

## 📁 Project Structure

```
Backend-API/
├── api/
│   ├── rates.js              # Main rates endpoint
│   ├── forex.js              # Forex rate endpoint
│   └── monitor-margins.js    # Automated monitoring
├── scrapers/
│   └── wiseComparison.js     # Wise API + fallback logic
├── analyze-margins.js        # Margin analysis script
├── vercel.json               # Vercel config + cron job
├── MAINTENANCE_GUIDE.md      # Your go-to guide
└── MARGIN_ANALYSIS.md        # Technical reference
```

## 🎯 Quick Commands

```bash
# Deploy
vercel --prod

# View logs
vercel logs dollar2rupee-api

# Test locally
node -e "const w = require('./scrapers/wiseComparison.js'); w.getAllRates('USD').then(r => console.log(r));"
```

---

**Last Updated**: January 2026  
**Status**: ✅ Production (Automated monitoring active)
