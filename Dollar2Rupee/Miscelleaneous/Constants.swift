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

        static let transfast = ""
        static let transferwise = ""
        static let remit2india = ""
        static let xoom = ""
        static let instarem = ""
        static let ria = ""
        static let remitly = ""
        static let westernunion = ""
        static let icici = ""
        static let remitmoney = ""
        
        static func valueByPropertyName(provider: String) -> String {
            switch provider {
            case "xoom": return APPStoreURLs.xoom
            case "icici": return APPStoreURLs.icici
            case "westernunion": return APPStoreURLs.westernunion
            case "remit2india": return APPStoreURLs.remit2india
            case "transferwise": return APPStoreURLs.transferwise
            case "ria": return APPStoreURLs.ria
            case "transfast": return APPStoreURLs.transfast
            case "remitly": return APPStoreURLs.remitly
            case "remitmoney": return APPStoreURLs.remitmoney
            case "instarem": return APPStoreURLs.instarem

            default:
                return ""
            }
        }
    }
    
}
