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
        
        let urlString = "\(ratesEndpoint)?currency=\(currency)&target=\(targetCurrency)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid API URL: \(urlString)")
            completion(.Error("Invalid API URL. Please check configuration."))
            return
        }
        
        print("📡 Fetching rates from: \(urlString)")
        
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
                            let source = rateJSON["source"].stringValue
                            let fee = rateJSON["fee"].doubleValue
                            let markup = rateJSON["markup"].doubleValue
                            
                            // Parse delivery time
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
                                let feeLabel = fee == 0.0 ? "Free ⭐" : String(format: "$%.2f", fee)
                                let speedLabel = deliverySpeed.isEmpty ? "" : " (\(deliverySpeed))"
                                print("   \(sourceLabel) \(provider): \(rate) (Fee: \(feeLabel))\(speedLabel)")
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
        
        let urlString = "\(forexEndpoint)?currency=\(currency)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid forex URL")
            completion(nil)
            return
        }
        
        print("📡 Fetching forex rate from: \(urlString)")
        
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
        let refreshURL = "\(ratesEndpoint)?currency=\(currency)&target=\(targetCurrency)&refresh=true"
        
        guard let url = URL(string: refreshURL) else {
            print("❌ Invalid refresh URL")
            completion(.Error("Invalid API URL"))
            return
        }
        
        print("🔄 Force refreshing rates for \(currency) → \(targetCurrency)...")
        
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
     Parse delivery speed from API response
     - Parameter rateJSON: JSON object containing delivery time data
     - Returns: User-friendly delivery speed string
     */
    private static func parseDeliverySpeed(from rateJSON: JSON) -> String {
        guard let deliveryTime = rateJSON["deliveryTime"].dictionary,
              let estimation = deliveryTime["deliveryEstimation"]?.dictionary else {
            return ""
        }
        
        // Check if provider gives estimate
        guard let givesEstimate = estimation["providerGivesEstimate"]?.boolValue,
              givesEstimate else {
            return ""
        }
        
        // Parse duration
        if let duration = estimation["duration"]?.dictionary {
            if let maxDuration = duration["max"]?.stringValue {
                return parseDurationString(maxDuration)
            } else if let minDuration = duration["min"]?.stringValue {
                return parseDurationString(minDuration)
            }
        }
        
        return ""
    }
    
    /**
     Convert ISO 8601 duration to user-friendly string
     - Parameter duration: ISO 8601 duration string (e.g., "PT1H", "P1D")
     - Returns: User-friendly string (e.g., "Instant", "1 hour", "1 day")
     */
    private static func parseDurationString(_ duration: String) -> String {
        // Handle instant/minutes (PT prefix)
        if duration.hasPrefix("PT") {
            let timeString = duration.replacingOccurrences(of: "PT", with: "")
            
            // Check for hours
            if timeString.contains("H") {
                if let hours = Int(timeString.replacingOccurrences(of: "H.*", with: "", options: .regularExpression)) {
                    if hours < 1 {
                        return "⚡ Instant"
                    } else if hours < 24 {
                        // Less than a day, show hours
                        if hours == 1 {
                            return "🕐 1 hour"
                        } else {
                            return "🕐 \(hours) hours"
                        }
                    } else {
                        // 24+ hours, convert to days
                        let days = hours / 24
                        if days == 1 {
                            return "📅 1 day"
                        } else {
                            return "📅 \(days) days"
                        }
                    }
                }
            }
            
            // Check for minutes
            if timeString.contains("M") {
                if let minutes = Int(timeString.replacingOccurrences(of: "M.*", with: "", options: .regularExpression)) {
                    if minutes < 60 {
                        return "⚡ Instant"
                    }
                }
            }
        }
        
        // Handle days (P prefix)
        if duration.hasPrefix("P") && duration.contains("D") {
            let dayString = duration.replacingOccurrences(of: "P", with: "").replacingOccurrences(of: "D.*", with: "", options: .regularExpression)
            if let days = Int(dayString) {
                if days == 1 {
                    return "📅 1 day"
                } else {
                    return "📅 \(days) days"
                }
            }
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

// MARK: - Result Enum (if not already defined)

enum Result<T> {
    case Success(T)
    case Error(String)
}

