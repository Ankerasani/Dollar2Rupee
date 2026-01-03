//
//  Constants.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 2/17/19.
//  Copyright © 2019 Ankersani. All rights reserved.
//

import Foundation

struct Constants {
    
    static func appStoreURL(appID: String) -> String {
        return "itms-apps://itunes.apple.com/app/\(appID)"
    }
    
    struct APPStoreURLs {

        // App Store URLs and Website URLs for providers
        static let transferwise = "https://wise.com/us/send-money/send-money-to-india"
        static let xoom = "https://www.xoom.com/india/send-money"
        static let instarem = "https://www.instarem.com/en-us/send-money-to-india"
        static let ria = "https://www.riamoneytransfer.com/en-us/send-money-to-india"
        static let remitly = "https://www.remitly.com/us/en/india"
        static let westernunion = "https://www.westernunion.com/us/en/send-money/start.html"
        static let icici = "https://www.icicibank.com/money2india/"
        static let moneygram = "https://www.moneygram.com/mgo/us/en/send/india"
        static let statebank = "https://www.sbiexpress.com/"
        static let ofx = "https://www.ofx.com/en-us/"
        static let chase = "https://www.chase.com/personal/international-wire-transfers"
        static let wellsfargo = "https://www.wellsfargo.com/financial-education/wire-transfers/"
        
        // Legacy providers (removed from API but may appear in cache)
        static let remit2india = "https://www.icicibank.com/money2india/"
        static let transfast = "https://www.westernunion.com/us/en/send-money/start.html"
        static let remitmoney = "https://www.remitly.com/us/en/india"
        
        static func valueByPropertyName(provider: String) -> String {
            switch provider {
            case "xoom": return APPStoreURLs.xoom
            case "icici": return APPStoreURLs.icici
            case "westernunion": return APPStoreURLs.westernunion
            case "transferwise": return APPStoreURLs.transferwise
            case "ria": return APPStoreURLs.ria
            case "remitly": return APPStoreURLs.remitly
            case "instarem": return APPStoreURLs.instarem
            case "moneygram": return APPStoreURLs.moneygram
            case "statebank": return APPStoreURLs.statebank
            case "ofx": return APPStoreURLs.ofx
            case "chase": return APPStoreURLs.chase
            case "wellsfargo": return APPStoreURLs.wellsfargo
            
            // Legacy providers (temporary, for cached data)
            case "remit2india": return APPStoreURLs.remit2india
            case "transfast": return APPStoreURLs.transfast
            case "remitmoney": return APPStoreURLs.remitmoney

            default:
                return ""
            }
        }
    }
    
    struct APPDeepLinks {
        
        // Deep link URL schemes for provider apps
        // These are used to check if the app is installed and open it directly
        static let transferwise = "wise://"
        static let xoom = "xoom://"
        static let instarem = "instarem://"
        static let ria = "riamoneytransfer://"
        static let remitly = "remitly://"
        static let westernunion = "westernunion://"
        static let moneygram = "moneygram://"
        static let chase = "chase://"
        static let wellsfargo = "wellsfargo://"
        
        // Providers without known deep links
        static let icici = ""
        static let statebank = ""
        static let ofx = ""
        static let remit2india = ""
        static let transfast = ""
        static let remitmoney = ""
        
        static func valueByPropertyName(provider: String) -> String {
            switch provider {
            case "xoom": return APPDeepLinks.xoom
            case "icici": return APPDeepLinks.icici
            case "westernunion": return APPDeepLinks.westernunion
            case "transferwise": return APPDeepLinks.transferwise
            case "ria": return APPDeepLinks.ria
            case "remitly": return APPDeepLinks.remitly
            case "instarem": return APPDeepLinks.instarem
            case "moneygram": return APPDeepLinks.moneygram
            case "statebank": return APPDeepLinks.statebank
            case "ofx": return APPDeepLinks.ofx
            case "chase": return APPDeepLinks.chase
            case "wellsfargo": return APPDeepLinks.wellsfargo
            
            // Legacy providers
            case "remit2india": return APPDeepLinks.remit2india
            case "transfast": return APPDeepLinks.transfast
            case "remitmoney": return APPDeepLinks.remitmoney

            default:
                return ""
            }
        }
    }
    
}
