# 🔧 Fix: APIService Not Found in Scope

## Problem
```
Cannot find 'APIService' in scope
- MainHandlers.swift:75
- MainHandlers.swift:88
```

## Root Cause
The `APIService.swift` file exists on disk but hasn't been added to your Xcode project's build target.

## Solution

### ✅ OPTION 1: Add Existing File to Xcode (RECOMMENDED)

#### Step-by-Step:

1. **Open Xcode Workspace**
   ```
   Open: Dollar2Rupee.xcworkspace
   (NOT Dollar2Rupee.xcodeproj)
   ```

2. **In Project Navigator (Left Sidebar)**
   - Find the `Dollar2Rupee` folder (blue icon)
   - Right-click on it
   - Select **"Add Files to Dollar2Rupee..."**

3. **Navigate to File**
   ```
   Go to: Dollar2Rupee/Services/APIService.swift
   ```
   
   If you don't see a `Services` folder, navigate to:
   ```
   Dollar2Rupee/Services/APIService.swift
   ```

4. **IMPORTANT: Check These Options**
   Before clicking "Add":
   - ☑️ **Copy items if needed** (checked)
   - ☑️ **Create groups** (selected, not folder references)
   - ☑️ **Add to targets: Dollar2Rupee** (checked)

5. **Click "Add"**

6. **Verify File Was Added**
   - You should see `APIService.swift` in Project Navigator
   - It should be under the `Dollar2Rupee` target

7. **Clean and Build**
   ```
   Cmd + Shift + K  (Clean Build Folder)
   Cmd + B          (Build)
   ```

8. **✅ Error Should Be Gone!**

---

### 🔄 OPTION 2: Create New File in Xcode

If Option 1 doesn't work, create the file directly in Xcode:

#### Step-by-Step:

1. **In Xcode Project Navigator**
   - Right-click on `Dollar2Rupee` folder
   - Select **New Group** → Name it `Services`
   - Right-click on `Services` group
   - Select **New File...**

2. **Choose Template**
   - Select **Swift File**
   - Click **Next**

3. **Name the File**
   - File name: `APIService.swift`
   - Make sure it's in the `Services` group
   - Make sure **Dollar2Rupee target** is checked
   - Click **Create**

4. **Copy the Contents**
   - Open the file in Finder:
     ```
     /Users/Sivashankar.Ankerasani1/Documents/Dollar2Rupee/
     Dollar2Rupee/Services/APIService.swift
     ```
   - Copy ALL the contents
   - Paste into the new file in Xcode

5. **Save**
   - Cmd + S

6. **Build**
   - Cmd + B

---

## Verification

After adding the file, verify it's working:

### 1. Check File is in Target
- Select `APIService.swift` in Project Navigator
- Open **File Inspector** (right sidebar)
- Under **Target Membership**:
  - ☑️ Dollar2Rupee (should be checked)

### 2. Check Imports
Your `MainHandlers.swift` should NOT need to import APIService:
```swift
// No need for: import APIService
// It's in the same target, so it's automatically available
```

### 3. Test Build
```bash
# In Xcode:
Cmd + Shift + K  # Clean
Cmd + B          # Build
```

Expected result: ✅ Build Succeeds

---

## File Contents Preview

The `APIService.swift` file contains:

```swift
import Foundation
import Alamofire
import SwiftyJSON

class APIService {
    
    // Base URL for Vercel deployment
    static let baseURL = "https://your-vercel-deployment.vercel.app"
    
    // Endpoints
    private static let ratesEndpoint = "\(baseURL)/api/rates"
    private static let forexEndpoint = "\(baseURL)/api/forex"
    
    // Main methods:
    static func fetchRates(completion: @escaping (Result<[Rate]>) -> Void)
    static func fetchForexRate(completion: @escaping (Double?) -> Void)
    static func forceRefreshRates(completion: @escaping (Result<[Rate]>) -> Void)
    static func testConnection(completion: @escaping (Bool) -> Void)
}
```

---

## Troubleshooting

### Issue 1: File Still Not Found After Adding

**Solution:**
1. Clean derived data:
   ```
   Xcode → Product → Clean Build Folder (Cmd + Shift + K)
   ```
2. Close Xcode
3. Delete DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Dollar2Rupee-*
   ```
4. Reopen `Dollar2Rupee.xcworkspace`
5. Build again

### Issue 2: Multiple APIService Files

**Solution:**
1. Search project for "APIService.swift"
2. Keep only ONE copy in the main Dollar2Rupee target
3. Delete any duplicates

### Issue 3: Target Membership Not Checked

**Solution:**
1. Select `APIService.swift` in Project Navigator
2. Open File Inspector (Cmd + Option + 1)
3. Under "Target Membership"
4. Check ☑️ Dollar2Rupee

---

## Why This Happened

The file was created in the filesystem but not added to the Xcode project. Xcode needs to know about files to include them in compilation.

### File System vs Xcode Project
```
File System:
✅ /Users/.../Dollar2Rupee/Services/APIService.swift

Xcode Project:
❌ Not listed in project.pbxproj
❌ Not part of build target
❌ Not compiled

Result: "Cannot find 'APIService' in scope"
```

After adding to Xcode:
```
File System:
✅ /Users/.../Dollar2Rupee/Services/APIService.swift

Xcode Project:
✅ Listed in project.pbxproj
✅ Part of Dollar2Rupee target
✅ Compiled with project

Result: ✅ APIService available everywhere!
```

---

## Quick Reference

**File Location:**
```
/Users/Sivashankar.Ankerasani1/Documents/Dollar2Rupee/
Dollar2Rupee/Services/APIService.swift
```

**How to Add:**
1. Right-click Dollar2Rupee folder in Xcode
2. "Add Files to Dollar2Rupee..."
3. Select `APIService.swift`
4. Check "Copy items" and "Add to targets"
5. Click "Add"
6. Clean + Build

**After Adding:**
- ✅ `APIService.fetchRates()` will work
- ✅ `APIService.fetchForexRate()` will work
- ✅ No import needed (same target)
- ✅ Build succeeds

---

## Summary

The file exists, it just needs to be added to your Xcode project. Follow Option 1 above, and the "Cannot find 'APIService'" error will be resolved!

🎯 **Next:** After adding the file, update the `baseURL` with your Vercel deployment URL!

