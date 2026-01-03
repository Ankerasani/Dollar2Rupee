//
//  APIService.swift
//  Dollar2Rupee
//
//  API Service for fetching real-time forex and remittance rates
//  Uses Wise Comparison API + Frankfurter API via Vercel backend
//

import Foundation
import Alamofire
import SwiftyJSON

class APIService {
    
    // MARK: - Configuration
    
    /// Base URL for your Vercel deployment
    /// Production URL (stable, auto-updates with new deployments)
    static let baseURL = "https://dollar2rupee-api.vercel.app"
    
    // Endpoints
    private static let ratesEndpoint = "\(baseURL)/api/rates"
    private static let forexEndpoint = "\(baseURL)/api/forex"
    
    // MARK: - Public Methods
    
    /**
     Fetch all remittance rates with comprehensive error handling
     - Parameter currency: Source currency code (USD, GBP, EUR, etc.)
     - Parameter targetCurrency: Target currency code (INR, PHP, MXN, etc.)
     - Parameter completion: Returns Result with array of Rate objects or error message
     */
    static func fetchRates(currency: String = "USD", targetCurrency: String = "INR", completion: @escaping (Result<[Rate]>) -> Void) {
        
        let endpoint = "\(baseURL)/api/rates?currency=\(currency)&target=\(targetCurrency)"
        
        guard let url = URL(string: endpoint) else {
            print("❌ Invalid API URL: \(endpoint)")
            completion(.Error("Invalid API URL. Please check configuration."))
            return
        }
        
        print("📡 Fetching rates from: \(endpoint)")
        
        Alamofire.request(url, method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        print("❌ No data received from API")
                        completion(.Error("No data received from server"))
                        return
                    }
                    
                    do {
                        let json = try JSON(data: data)
                        
                        // Check if API call was successful
                        guard json["success"].boolValue else {
                            let errorMsg = json["error"].stringValue
                            print("❌ API returned error: \(errorMsg)")
                            completion(.Error(errorMsg.isEmpty ? "Server returned an error" : errorMsg))
                            return
                        }
                        
                        // Check for warnings (e.g., using cached data or fallback)
                        if let warning = json["warning"].string {
                            print("⚠️  API Warning: \(warning)")
                        }
                        
                        // Log data source info
                        let fallbackLevel = json["fallbackLevel"].stringValue
                        let wiseApiCount = json["sources"]["wiseApi"].intValue
                        let calculatedCount = json["sources"]["calculated"].intValue
                        
                        print("📊 Data source: \(fallbackLevel.isEmpty ? "primary" : fallbackLevel)")
                        print("   - Wise API: \(wiseApiCount) providers")
                        print("   - Calculated: \(calculatedCount) providers")
                        
                        // Get forex rate
                        let forexRate = json["forexRate"]["rate"].doubleValue
                        let forexRateString = String(format: "%.2f", forexRate)
                        
                        // Parse rates array
                        let ratesArray = json["rates"].arrayValue
                        var rates: [Rate] = []
                        
                        for rateJSON in ratesArray {
                            let provider = rateJSON["provider"].stringValue
                            let rate = rateJSON["rate"].doubleValue
                            let fee = rateJSON["fee"].doubleValue
                            let markup = rateJSON["markup"].doubleValue
                            let source = rateJSON["source"].stringValue
                            let deliverySpeed = parseDeliverySpeed(from: rateJSON)
                            
                            if rate > 0 {
                                let rateObject = Rate(
                                    currency: provider,
                                    rate: rate,
                                    dateString: Date().toString(dateFormat: "dd-MMM-yyyy"),
                                    forexRate: forexRateString,
                                    sourceCurrency: currency,
                                    fee: fee,
                                    markup: markup,
                                    deliverySpeed: deliverySpeed
                                )
                                rates.append(rateObject)
                                
                                // Log individual rates for debugging
                                let sourceLabel = source == "wise-api" ? "✅ Real" : "📐 Calc"
                                let feeDisplay = fee == 0.0 ? "Free ⭐" : String(format: "$%.2f", fee)
                                let speedDisplay = deliverySpeed.isEmpty ? "" : " (\(deliverySpeed))"
                                print("   \(sourceLabel) \(provider): \(rate) (Fee: \(feeDisplay))\(speedDisplay)")
                            }
                        }
                        
                        guard !rates.isEmpty else {
                            print("❌ No valid rates in API response")
                            completion(.Error("No rates available"))
                            return
                        }
                        
                        print("✅ Successfully fetched \(rates.count) rates")
                        completion(.Success(rates))
                        
                    } catch {
                        print("❌ Error parsing API response:", error)
                        completion(.Error("Failed to parse server response"))
                    }
                    
                case .failure(let error):
                    print("❌ Network error:", error.localizedDescription)
                    
                    // Provide user-friendly error messages
                    var errorMessage = "Network error"
                    if let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case 404:
                            errorMessage = "API endpoint not found. Please check deployment."
                        case 500...599:
                            errorMessage = "Server error. Please try again later."
                        case 0:
                            errorMessage = "No internet connection"
                        default:
                            errorMessage = "Network error (\(statusCode))"
                        }
                    } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                        errorMessage = "No internet connection"
                    } else if (error as NSError).code == NSURLErrorTimedOut {
                        errorMessage = "Request timed out. Please try again."
                    }
                    
                    completion(.Error(errorMessage))
                }
            }
    }
    
    /**
     Fetch forex rate only
     - Parameter currency: Source currency code (USD, GBP, EUR, etc.)
     - Parameter completion: Returns forex rate as Double or nil
     */
    static func fetchForexRate(currency: String = "USD", completion: @escaping (Double?) -> Void) {
        
        let endpoint = "\(baseURL)/api/forex?currency=\(currency)"
        
        guard let url = URL(string: endpoint) else {
            print("❌ Invalid forex URL")
            completion(nil)
            return
        }
        
        print("📡 Fetching forex rate from: \(endpoint)")
        
        Alamofire.request(url, method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        print("❌ No forex data received")
                        completion(nil)
                        return
                    }
                    
                    do {
                        let json = try JSON(data: data)
                        
                        if json["success"].boolValue, let rate = json["rate"].double {
                            let source = json["source"].stringValue
                            print("✅ Fetched forex rate: \(rate) from \(source)")
                            completion(rate)
                        } else {
                            print("❌ Invalid forex response")
                            completion(nil)
                        }
                        
                    } catch {
                        print("❌ Error parsing forex response:", error)
                        completion(nil)
                    }
                    
                case .failure(let error):
                    print("❌ Forex network error:", error.localizedDescription)
                    completion(nil)
                }
            }
    }
    
    /**
     Force refresh rates (bypass cache)
     - Parameter currency: Source currency code (USD, GBP, EUR, etc.)
     - Parameter completion: Returns Result with array of Rate objects or error
     */
    static func forceRefreshRates(currency: String = "USD", targetCurrency: String = "INR", completion: @escaping (Result<[Rate]>) -> Void) {
        let refreshURL = "\(baseURL)/api/rates?currency=\(currency)&target=\(targetCurrency)&refresh=true"
        
        guard let url = URL(string: refreshURL) else {
            print("❌ Invalid refresh URL")
            completion(.Error("Invalid API URL"))
            return
        }
        
        print("🔄 Force refreshing rates...")
        
        Alamofire.request(url, method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        print("❌ No data received")
                        completion(.Error("No data received"))
                        return
                    }
                    
                    do {
                        let json = try JSON(data: data)
                        
                        guard json["success"].boolValue else {
                            let errorMsg = json["error"].stringValue
                            print("❌ Force refresh failed: \(errorMsg)")
                            completion(.Error(errorMsg))
                            return
                        }
                        
                        let forexRate = json["forexRate"]["rate"].doubleValue
                        let forexRateString = String(format: "%.2f", forexRate)
                        
                        let ratesArray = json["rates"].arrayValue
                        var rates: [Rate] = []
                        
                        for rateJSON in ratesArray {
                            let provider = rateJSON["provider"].stringValue
                            let rate = rateJSON["rate"].doubleValue
                            let fee = rateJSON["fee"].doubleValue
                            let markup = rateJSON["markup"].doubleValue
                            let source = rateJSON["source"].stringValue
                            let deliverySpeed = parseDeliverySpeed(from: rateJSON)
                            
                            if rate > 0 {
                                let rateObject = Rate(
                                    currency: provider,
                                    rate: rate,
                                    dateString: Date().toString(dateFormat: "dd-MMM-yyyy"),
                                    forexRate: forexRateString,
                                    sourceCurrency: currency,
                                    fee: fee,
                                    markup: markup,
                                    deliverySpeed: deliverySpeed
                                )
                                rates.append(rateObject)
                            }
                        }
                        
                        print("✅ Force refreshed \(rates.count) rates")
                        completion(.Success(rates))
                        
                    } catch {
                        print("❌ Error parsing refresh response:", error)
                        completion(.Error("Failed to parse response"))
                    }
                    
                case .failure(let error):
                    print("❌ Force refresh network error:", error.localizedDescription)
                    completion(.Error(error.localizedDescription))
                }
            }
    }
    
    // MARK: - Helper Methods
    
    /**
     Parse delivery speed from ISO 8601 duration format
     - Parameter json: The rate JSON object containing deliveryTime
     - Returns: User-friendly delivery speed string (e.g., "⚡ Instant", "📅 3 days")
     */
    private static func parseDeliverySpeed(from json: JSON) -> String {
        guard json["deliveryTime"]["providerGivesEstimate"].boolValue == true,
              let durationString = json["deliveryTime"]["duration"]["max"].string ?? json["deliveryTime"]["duration"]["min"].string else {
            return ""
        }
        
        // Handle ISO 8601 duration format (e.g., "PT1H", "P2D")
        let cleanedDuration = durationString.replacingOccurrences(of: "P", with: "").replacingOccurrences(of: "T", with: "")
        
        if cleanedDuration.contains("H") {
            if let hoursString = cleanedDuration.replacingOccurrences(of: "H", with: "").components(separatedBy: "M").first,
               let hours = Int(hoursString) {
                if hours == 0 {
                    return "⚡ Instant"
                } else if hours < 24 {
                    return "🕐 \(hours) hours"
                } else {
                    let days = hours / 24
                    return "📅 \(days) day\(days > 1 ? "s" : "")"
                }
            }
        } else if cleanedDuration.contains("D") {
            if let daysString = cleanedDuration.replacingOccurrences(of: "D", with: "").components(separatedBy: "H").first,
               let days = Int(daysString) {
                return "📅 \(days) day\(days > 1 ? "s" : "")"
            }
        } else if cleanedDuration.contains("M") { // Minutes
            if let minutesString = cleanedDuration.replacingOccurrences(of: "M", with: "").components(separatedBy: "S").first,
               let minutes = Int(minutesString), minutes < 60 {
                return "⚡ Instant"
            }
        } else if cleanedDuration.contains("S") { // Seconds
            return "⚡ Instant"
        }
        
        return ""
    }
    
    /**
     Test if API is reachable
     - Parameter completion: Returns true if API responds, false otherwise
     */
    static func testConnection(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: forexEndpoint) else {
            completion(false)
            return
        }
        
        Alamofire.request(url, method: .get)
            .validate(statusCode: 200..<300)
            .response { response in
                completion(response.error == nil)
            }
    }
}

