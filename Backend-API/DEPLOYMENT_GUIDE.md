# 🚀 Dollar2Rupee Backend API - Complete Setup Guide

## 📋 Table of Contents
1. [Quick Start](#quick-start)
2. [Option 1: Vercel (Free & Easy)](#option-1-vercel-free--easy)
3. [Option 2: AWS Lambda (Scalable)](#option-2-aws-lambda-scalable)
4. [Option 3: Heroku (Simple)](#option-3-heroku-simple)
5. [Testing Your API](#testing-your-api)
6. [Integrating with iOS App](#integrating-with-ios-app)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Quick Start

### What You Built:
A **serverless API** that:
- ✅ Scrapes exchange rates from provider websites
- ✅ Caches results for 30 minutes
- ✅ Provides JSON API for your iOS app
- ✅ Runs automatically every 30 minutes
- ✅ Costs $0/month (with free tier)

### API Endpoints:
```
GET /api/rates     - Get all remittance rates
GET /api/forex     - Get forex rate only
```

---

## Option 1: Vercel (Free & Easy) ⭐ RECOMMENDED

### Why Vercel?
- ✅ **100% FREE** for your use case
- ✅ **Automatic deployments** from GitHub
- ✅ **Built-in cron jobs** (runs every 30 min)
- ✅ **Global CDN** (fast worldwide)
- ✅ **Zero configuration**
- ✅ **HTTPS included**

### Step-by-Step Deployment:

#### 1. Install Vercel CLI
```bash
# Open Terminal and run:
npm install -g vercel

# Or if you don't have npm:
brew install vercel-cli
```

#### 2. Navigate to Backend Folder
```bash
cd /Users/Sivashankar.Ankerasani1/Documents/Dollar2Rupee/Backend-API
```

#### 3. Install Dependencies
```bash
npm install
```

#### 4. Test Locally (Optional)
```bash
npm run dev

# Test in browser:
# http://localhost:3000/api/rates
```

#### 5. Deploy to Vercel
```bash
vercel

# Follow the prompts:
# - Login with GitHub/Email
# - Confirm project name
# - Done!
```

#### 6. Get Your API URL
After deployment, Vercel will show:
```
✅ Deployed to https://your-app-name.vercel.app
```

**Copy this URL!** You'll use it in your iOS app.

---

### Setting Up GitHub Auto-Deploy (Optional but Recommended)

```bash
# 1. Initialize git in Backend-API folder
cd /Users/Sivashankar.Ankerasani1/Documents/Dollar2Rupee/Backend-API
git init
git add .
git commit -m "Initial backend commit"

# 2. Create repo on GitHub (via website)
# Name it: dollar2rupee-api

# 3. Push to GitHub
git remote add origin https://github.com/YOUR_USERNAME/dollar2rupee-api.git
git push -u origin main

# 4. Connect to Vercel
# - Go to vercel.com
# - Click "Import Project"
# - Select your GitHub repo
# - Click "Deploy"
```

**Now every time you push to GitHub, Vercel auto-deploys!**

---

## Option 2: AWS Lambda (Scalable)

### Why AWS Lambda?
- ✅ **Free tier:** 1M requests/month
- ✅ **Very scalable**
- ✅ **Reliable**

### Quick Setup with Serverless Framework:

```bash
# 1. Install Serverless
npm install -g serverless

# 2. Configure AWS credentials
serverless config credentials --provider aws --key YOUR_KEY --secret YOUR_SECRET

# 3. Deploy
cd Backend-API
serverless deploy

# Your API URL will be shown in output
```

---

## Option 3: Heroku (Simple)

### Why Heroku?
- ✅ **Very simple** to use
- ✅ **Free tier** available
- ✅ **Add-ons** for databases

### Setup:

```bash
# 1. Install Heroku CLI
brew tap heroku/brew && brew install heroku

# 2. Login
heroku login

# 3. Create app
heroku create dollar2rupee-api

# 4. Deploy
git push heroku main

# Your API URL: https://dollar2rupee-api.herokuapp.com
```

---

## 🧪 Testing Your API

### Test in Browser:
```
https://your-app-name.vercel.app/api/rates
```

### Test with cURL:
```bash
# Get rates
curl https://your-app-name.vercel.app/api/rates

# Get forex only
curl https://your-app-name.vercel.app/api/forex

# Force refresh (bypass cache)
curl https://your-app-name.vercel.app/api/rates?refresh=true
```

### Expected Response:
```json
{
  "success": true,
  "forexRate": {
    "rate": 83.25,
    "date": "2025-01-02",
    "timestamp": "2025-01-02T10:30:00.000Z"
  },
  "rates": [
    {
      "provider": "transferwise",
      "rate": 82.15,
      "timestamp": "2025-01-02T10:30:00.000Z"
    },
    {
      "provider": "xoom",
      "rate": 81.98,
      "timestamp": "2025-01-02T10:30:00.000Z"
    }
  ],
  "timestamp": "2025-01-02T10:30:00.000Z",
  "count": 11,
  "cached": false
}
```

---

## 📱 Integrating with iOS App

### Step 1: Update API URL in MainHandlers.swift

I already updated the code, but you need to replace the placeholder URL:

```swift
// In MainHandlers.swift, find these lines and replace:

// Line ~75:
let apiURL = "https://your-app-name.vercel.app/api/forex"

// Line ~98:
let apiURL = "https://your-app-name.vercel.app/api/rates"
```

**Replace `your-app-name.vercel.app` with your actual Vercel URL!**

### Step 2: Test in iOS App

```bash
# 1. Open Xcode
cd /Users/Sivashankar.Ankerasani1/Documents/Dollar2Rupee
open Dollar2Rupee.xcworkspace

# 2. Build and run on simulator

# 3. Check Xcode console for logs:
# ✅ Successfully fetched 11 rates from API
```

### Step 3: Handle Errors

The code already handles:
- ✅ Network errors
- ✅ Invalid responses
- ✅ Fallback to cached Core Data

---

## 🔍 Monitoring & Analytics

### View Logs in Vercel:
```bash
# Real-time logs
vercel logs your-app-name.vercel.app

# Or view in dashboard:
# https://vercel.com/dashboard
```

### Check API Performance:
- Go to Vercel dashboard
- Click your project
- View "Analytics" tab
- See request count, response times

---

## 🛠 Customizing Your API

### Add More Providers:

Edit `Backend-API/scrapers/rateScraper.js`:

```javascript
const providers = [
  { name: 'xoom', url: 'https://www.xoom.com/...' },
  { name: 'newprovider', url: 'https://newprovider.com/...' },
  // Add more here
];
```

### Change Cache Duration:

Edit `Backend-API/api/rates.js`:

```javascript
// Change from 30 minutes to 1 hour:
const CACHE_DURATION = 60 * 60 * 1000; // 1 hour
```

### Add Authentication (Optional):

```javascript
// In api/rates.js, add:
const API_KEY = process.env.API_KEY;

if (req.headers['x-api-key'] !== API_KEY) {
  return res.status(401).json({ error: 'Unauthorized' });
}
```

Then set environment variable in Vercel dashboard.

---

## 🚨 Troubleshooting

### Problem: "Cannot find module 'axios'"
**Solution:**
```bash
cd Backend-API
npm install
```

### Problem: Vercel deployment fails
**Solution:**
```bash
# Check vercel.json is correct
# Make sure package.json has all dependencies
npm install --save axios cheerio
```

### Problem: Scrapers return empty data
**Solution:**
- Websites may have changed HTML structure
- Some sites may block scraping
- Use alternative data sources
- Consider using official APIs if available

### Problem: iOS app shows "No data"
**Solution:**
```swift
// Check API URL is correct in MainHandlers.swift
// Check Xcode console for errors
// Test API URL in browser first
```

---

## 💡 Pro Tips

1. **Use Environment Variables:**
   ```bash
   # In Vercel dashboard, add:
   # Environment Variables > Add
   # Name: API_KEY
   # Value: your-secret-key
   ```

2. **Monitor Rate Limits:**
   - Most websites limit requests
   - Add delays between scrapes
   - Respect robots.txt

3. **Add More Data Sources:**
   - Don't rely on single source
   - Aggregate from multiple sites
   - Use official APIs when possible

4. **Set Up Alerts:**
   ```bash
   # Vercel can send Slack/email alerts
   # Dashboard > Integrations > Slack
   ```

---

## 📊 Performance Optimization

### Enable Redis Caching (Advanced):

```bash
# Add Redis (Vercel KV or Upstash)
npm install @vercel/kv

# Update api/rates.js to use Redis instead of memory cache
```

### Add Database for History:

```bash
# Use Vercel Postgres or MongoDB Atlas
npm install @vercel/postgres

# Store historical rates for trend analysis
```

---

## 🔒 Security Best Practices

1. **Rate Limiting:**
   ```javascript
   // Add to api/rates.js
   const rateLimit = require('express-rate-limit');
   ```

2. **CORS Configuration:**
   ```javascript
   // Only allow your iOS app
   res.setHeader('Access-Control-Allow-Origin', 'https://yourapp.com');
   ```

3. **API Key (Production):**
   ```javascript
   if (req.headers['x-api-key'] !== process.env.API_KEY) {
     return res.status(401).end();
   }
   ```

---

## 📞 Support

### Need Help?
1. Check Vercel docs: https://vercel.com/docs
2. Test API endpoint in browser
3. Check Vercel logs for errors
4. Verify iOS code has correct URL

---

## 🎉 Success Checklist

- [ ] Backend API deployed to Vercel
- [ ] API URL accessible in browser
- [ ] `/api/rates` returns JSON data
- [ ] `/api/forex` returns forex rate
- [ ] Updated iOS app with correct API URL
- [ ] Tested in iOS simulator
- [ ] Rates display in app
- [ ] Cron job scheduled (check Vercel dashboard)

---

**You're all set! Your API will now update rates automatically every 30 minutes. 🚀**

