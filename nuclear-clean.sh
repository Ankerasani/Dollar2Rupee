#!/bin/bash

# Nuclear Clean Script for Xcode
# This will force delete ALL build caches

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║          🧹 NUCLEAR CLEAN - Deleting ALL Xcode Caches          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# 1. Delete DerivedData
echo "🗑️  Deleting DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "✅ DerivedData deleted"
echo ""

# 2. Delete Module Cache
echo "🗑️  Deleting Module Cache..."
rm -rf ~/Library/Developer/Xcode/ModuleCache.noindex/*
echo "✅ Module Cache deleted"
echo ""

# 3. Delete Build folder in project
echo "🗑️  Deleting project build folder..."
cd /Users/Sivashankar.Ankerasani1/Documents/Dollar2Rupee
rm -rf build/
echo "✅ Build folder deleted"
echo ""

# 4. Clean CocoaPods cache
echo "🗑️  Cleaning CocoaPods cache..."
cd /Users/Sivashankar.Ankerasani1/Documents/Dollar2Rupee
pod deintegrate 2>/dev/null || true
pod install
echo "✅ CocoaPods reinstalled"
echo ""

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ CLEAN COMPLETE!                           ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "NOW DO THIS IN XCODE:"
echo "1. Open Xcode"
echo "2. Product > Clean Build Folder (Cmd+Shift+K)"
echo "3. Product > Build (Cmd+B)"
echo "4. Product > Run (Cmd+R)"
echo ""
echo "Console should show: https://dollar2rupee-api.vercel.app"
echo "NOT: https://dollar2rupee-91pkmxcb2..."
echo ""

