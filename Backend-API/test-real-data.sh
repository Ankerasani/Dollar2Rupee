#!/bin/bash

echo "=================================================="
echo "🚀 Dollar2Rupee Backend - REAL DATA TEST"
echo "=================================================="
echo ""
echo "⚠️  NO MOCK DATA - This will test REAL scraping"
echo ""

# Check if in correct directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Run this from the Backend-API directory"
    echo ""
    echo "Run: cd Backend-API && ./test-real-data.sh"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install --silent

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed"
echo ""

# Run test
echo "🧪 Testing REAL data sources..."
echo ""
node test-scraper.js

if [ $? -eq 0 ]; then
    echo ""
    echo "=================================================="
    echo "✅ SUCCESS! Real data verified!"
    echo "=================================================="
    echo ""
    echo "Next steps:"
    echo "1. Deploy to Vercel: vercel"
    echo "2. Copy the deployment URL"
    echo "3. Update MainHandlers.swift with your URL"
    echo ""
else
    echo ""
    echo "=================================================="
    echo "❌ FAILED - Some sources didn't work"
    echo "=================================================="
    echo ""
    echo "This is OK if at least one source succeeded."
    echo "Check output above for details."
    echo ""
    echo "See REAL_DATA_IMPLEMENTATION.md for debugging."
    echo ""
    exit 1
fi

