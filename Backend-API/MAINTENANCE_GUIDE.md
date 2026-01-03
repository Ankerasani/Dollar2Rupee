# Dollar2Rupee Backend API - Maintenance Guide

## 🚀 Quick Start

Your backend API is deployed at: **https://dollar2rupee-api.vercel.app**

**Automated monitoring runs daily at midnight UTC (5:30 AM IST)**

---

## ⚠️ What To Do When Margins Change

### 6 Simple Steps (~10 minutes):

#### 1️⃣ Check Vercel Logs (2 min)
- Go to: https://vercel.com/newsapps-projects-60e3aa11/dollar2rupee-api
- Click "Functions" → `monitor-margins`
- See which providers changed

#### 2️⃣ Run Analysis Script (2 min)
```bash
cd /Users/Sivashankar.Ankerasani1/Documents/Dollar2Rupee/Backend-API
node analyze-margins.js
```

Wait for it to complete (~30-60 seconds). It will fetch current rates and calculate exact margins.

#### 3️⃣ Update 2 Files (3 min)

**File 1: `scrapers/wiseComparison.js`**
- Update `providerMargins` at **line ~115** (in `calculateMissingRates`)
- Update `providerMargins` at **line ~204** (in `calculateAllRatesFromForex`)
- Update `EMERGENCY_RATES` at **line ~151**

**File 2: `api/monitor-margins.js`**
- Update `CURRENT_MARGINS` at **line ~14**

💡 **Tip**: Just copy-paste the `providerMargins` object from the script output!

#### 4️⃣ Deploy (1 min)
```bash
cd /Users/Sivashankar.Ankerasani1/Documents/Dollar2Rupee/Backend-API
vercel --prod
```

#### 5️⃣ Verify (1 min)
```bash
curl https://dollar2rupee-api.vercel.app/api/monitor-margins
```

Should show: `"status": "ok"` ✅

#### 6️⃣ Test iOS App (1 min)
- Open app
- Check rates look good
- Done! ✅

---

## 🔍 How It Works

### Data Sources (4-Level Fallback)
1. **Wise API** (Primary) - Real-time rates from Wise Comparison API
2. **Calculated from Forex** - Live forex rate + provider margins
3. **Server Cache** - Last successful API response (24-hour TTL)
4. **Emergency Static Rates** - Hardcoded fallback (rarely used)

### Automated Monitoring
- **Schedule**: Daily at midnight UTC (5:30 AM IST)
- **Alert Threshold**: 0.5 INR change
- **What It Checks**: Compares actual margins vs configured margins for USD, GBP, EUR
- **Action Required**: Only when alerted

### Provider Margins
The system uses pre-analyzed margins for each provider:
- **Wise**: 0.0 INR (mid-market rate)
- **Instarem**: -0.21 INR
- **Western Union**: -0.15 INR
- **State Bank**: -0.30 INR
- **MoneyGram**: -0.36 INR
- **Remitly**: -0.53 INR
- **Xoom**: -1.06 INR
- **OFX**: -2.71 INR
- **Ria**: -4.50 INR

These margins are recalculated periodically based on real API data.

---

## 📋 API Endpoints

### Get Rates
```bash
GET /api/rates?currency=USD
GET /api/rates?currency=GBP
GET /api/rates?currency=EUR
# ... etc
```

Returns: Array of providers with rates for specified currency

### Get Forex Rate
```bash
GET /api/forex?currency=USD
```

Returns: Current forex rate (mid-market)

### Monitor Margins (Automated)
```bash
GET /api/monitor-margins
```

Returns: Current margin analysis with alerts

---

## 🆘 Troubleshooting

### "Still getting alerts after updating"
- Make sure you updated BOTH files
- Margins must match exactly in both files
- Redeploy to Vercel
- Wait 30 seconds for deployment to propagate

### "Should I update for small changes?"
- < 0.5 INR: Optional (within normal variance)
- 0.5-1.0 INR: Recommended
- > 1.0 INR: Definitely update

### "analyze-margins.js fails"
- Check internet connection
- Wise API might be down (try again in 10 minutes)
- Can manually calculate: `newMargin = providerRate - forexRate`

---

## 📅 Maintenance Schedule

**Daily (Automatic)**:
- Monitoring runs at midnight UTC
- No action needed ✅

**Weekly (Quick Check)**:
- Check Vercel logs (30 seconds)
- See if there are any warnings
- Update if needed

**When Alerted** (~1-2 weeks maybe):
- Follow 6 steps above (~10 minutes)
- Update and deploy

**Quarterly (Optional)**:
- Full manual review
- Verify everything looks good

---

## 🔧 Quick Commands

```bash
# Go to Backend-API folder
cd /Users/Sivashankar.Ankerasani1/Documents/Dollar2Rupee/Backend-API

# Run analysis
node analyze-margins.js

# Deploy
vercel --prod

# Test monitoring
curl https://dollar2rupee-api.vercel.app/api/monitor-margins

# Test rates API
curl https://dollar2rupee-api.vercel.app/api/rates?currency=USD

# View Vercel logs
vercel logs dollar2rupee-api
```

---

## 📞 Important Links

- **Vercel Dashboard**: https://vercel.com/newsapps-projects-60e3aa11/dollar2rupee-api
- **API Base URL**: https://dollar2rupee-api.vercel.app
- **Monitor Endpoint**: https://dollar2rupee-api.vercel.app/api/monitor-margins

---

## 🎯 Summary

✅ Automated monitoring keeps margins accurate  
✅ Only act when alerted (~10 minutes every 1-2 weeks)  
✅ Low maintenance, high accuracy  
✅ No calendar reminders needed  

**The system watches for you!** 🎉

