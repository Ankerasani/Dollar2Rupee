# Response to Apple App Review Team
## Dollar2Rupee - Resolution Center Reply

---

### Dear App Review Team,

Thank you for your feedback. I have addressed both issues and would like to provide clarification:

---

## ✅ Issue 1: Screenshot Problem (Guideline 2.3.3) - RESOLVED

**Action Taken:**
I have [CHOOSE ONE]:
- [ ] Removed all iPad screenshots and submitted as iPhone-only app
- [ ] Replaced iPad screenshots with correctly sized 12.9" iPad Pro screenshots (2048 x 2732 pixels)

The screenshots now accurately reflect the app interface on the correct device frames.

---

## ⚠️ Issue 2: Business Model Clarification (Guideline 3.2.1)

**Important Clarification:**

There appears to be a misunderstanding about the nature of Dollar2Rupee. **Dollar2Rupee is NOT a financial institution.**

### What Dollar2Rupee IS:
Dollar2Rupee is an **independent rate comparison application**, functionally similar to:
- **Kayak** (compares flight prices from airlines)
- **Trivago** (compares hotel prices)
- **NerdWallet** (compares financial products)
- **Google Shopping** (compares product prices)

### What We Do:
✅ Display publicly available exchange rates  
✅ Compare rates from multiple money transfer providers  
✅ Direct users to official provider websites/apps via "View Offer" button  
✅ Provide comparison information only  

### What We DO NOT Do:
❌ Process money transfers  
❌ Hold or transmit customer funds  
❌ Collect payment information  
❌ Act as a financial institution  
❌ Provide financial services of any kind  

### Technical Implementation:
The app compares rates from these **third-party providers**:
- Xoom (owned by PayPal)
- TransferWise (Wise)
- Remit2India
- Western Union
- Remitly
- InstareM
- Ria Money Transfer
- And others

When users tap "View Offer", they are taken to the provider's official website using **SFSafariViewController** (with visible Safari controls) or to the provider's App Store page. The user then completes their transaction **directly with that provider** - not with Dollar2Rupee.

### Code Changes Made:
1. **Removed custom WKWebView browser** - Previously used a custom browser view
2. **Now using SFSafariViewController** - Users see official Safari UI and clearly know they're leaving the app
3. **Added disclosure text** - In-app disclaimer states: *"Dollar2Rupee is an independent comparison tool. We don't process transfers. Tap 'View Offer' to visit the provider's website."*
4. **Updated button text** - Changed from "SEND" to "VIEW OFFER" to clarify we're linking to external services
5. **Updated App Store description** - Clearly explains we are a comparison tool, not a financial service provider

### Publisher Information:
This app is published under **[Your Developer Name]**, the legitimate creator and owner of this comparison tool. We are not representing any financial institution, just as:
- Kayak doesn't need to be published by Delta Airlines
- Trivago doesn't need to be published by Marriott
- Google Shopping doesn't need to be published by Amazon

### App Store Metadata Clarification:
- **App Name:** Dollar2Rupee - Compare Rates
- **Category:** Finance / Utilities (comparison tool)
- **Description:** Clearly states we are an "independent comparison tool"
- **No claims** of being a financial institution anywhere in metadata

If there is specific metadata that caused confusion about our business model, please let me know and I will clarify it immediately.

### Compliance with Guidelines:
- **Guideline 2.5.6:** Now using SFSafariViewController for web content
- **Guideline 3.1.1:** We don't process payments - users pay the provider directly
- **Guideline 3.2.1:** We are not a financial institution requiring special account status
- **Guideline 4.2:** App provides genuine utility as a comparison tool

---

## 📝 Additional Information:

**Question:** Do you need any additional documentation to verify that:
1. Dollar2Rupee is a comparison service, not a financial institution?
2. We don't process transactions or hold funds?
3. The providers we list are independent third-party companies?

I'm happy to provide any clarification needed.

**Disclosure:** [CHOOSE ONE]
- [ ] We do NOT receive affiliate commissions or referral payments from providers
- [ ] We may receive affiliate commissions from some providers (this is disclosed in our App Description)

---

Thank you for your time and consideration. I believe these changes address the concerns while maintaining compliance with all App Store guidelines.

**All changes have been made to the app metadata only - no new binary is required.**

Please let me know if you need any additional information or clarification.

Best regards,  
[Your Name]  
[Your Developer Account Name]

---

## 📎 Supporting Information

### Similar Apps on App Store:
These comparison apps are published by independent developers (not the service providers):
- "Best Exchange Rates" (currency comparison)
- "Money Transfer Comparison" apps
- Various financial comparison tools

### User Flow in Our App:
1. User opens Dollar2Rupee app
2. User enters amount to transfer
3. App displays comparison of rates (public information)
4. User taps "View Offer" on preferred provider
5. **SFSafariViewController opens** showing provider's official website
6. User sees Safari controls (address bar, done button, etc.)
7. User completes transaction on provider's site
8. Dollar2Rupee never touches money or user data

This is standard functionality for comparison/aggregator apps and complies with all App Store guidelines.

