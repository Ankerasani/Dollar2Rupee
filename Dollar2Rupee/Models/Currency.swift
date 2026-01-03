//
//  Currency.swift
//  Dollar2Rupee
//
//  Multi-currency support model
//

import Foundation

struct Currency {
    let code: String        // "USD", "GBP", "EUR", etc.
    let name: String        // "US Dollar", "British Pound", etc.
    let symbol: String      // "$", "£", "€", etc.
    let flag: String        // "🇺🇸", "🇬🇧", "🇪🇺", etc.
    
    // All supported currencies
    static let allCurrencies: [Currency] = [
        Currency(code: "USD", name: "US Dollar", symbol: "$", flag: "🇺🇸"),
        Currency(code: "GBP", name: "British Pound", symbol: "£", flag: "🇬🇧"),
        Currency(code: "EUR", name: "Euro", symbol: "€", flag: "🇪🇺"),
        Currency(code: "CAD", name: "Canadian Dollar", symbol: "C$", flag: "🇨🇦"),
        Currency(code: "AUD", name: "Australian Dollar", symbol: "A$", flag: "🇦🇺"),
        Currency(code: "SGD", name: "Singapore Dollar", symbol: "S$", flag: "🇸🇬")
    ]
    
    // Get currency by code
    static func currency(for code: String) -> Currency? {
        return allCurrencies.first { $0.code == code }
    }
    
    // Default currency
    static let `default` = allCurrencies[0] // USD
}

// Currency Manager for UserDefaults
class CurrencyManager {
    
    static let shared = CurrencyManager()
    
    private let userDefaults = UserDefaults.standard
    private let selectedCurrencyKey = "selectedCurrencyCode"
    
    private init() {}
    
    // Get currently selected currency
    var selectedCurrency: Currency {
        get {
            let code = userDefaults.string(forKey: selectedCurrencyKey) ?? Currency.default.code
            return Currency.currency(for: code) ?? Currency.default
        }
        set {
            userDefaults.set(newValue.code, forKey: selectedCurrencyKey)
            userDefaults.synchronize()
            
            // Post notification for currency change
            NotificationCenter.default.post(name: .currencyDidChange, object: newValue)
        }
    }
}

// Notification for currency changes
extension Notification.Name {
    static let currencyDidChange = Notification.Name("currencyDidChange")
}

