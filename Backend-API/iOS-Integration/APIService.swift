// API Service for Dollar2Rupee
// Replace MainHandlers.swift API calls with this

import Foundation
import Alamofire
import SwiftyJSON

class APIService {
    
    // MARK: - Configuration
    
    // TODO: Replace with your actual API URL after deployment
    static let baseURL = "https://your-app-name.vercel.app"
    
    // Endpoints
    private static let ratesEndpoint = "\(baseURL)/api/rates"
    private static let forexEndpoint = "\(baseURL)/api/forex"
    
    // MARK: - Response Models
    
    struct APIResponse: Decodable {
        let success: Bool
        let rates: [RateData]?
        let forexRate: ForexData?
        let timestamp: String
        let count: Int?
        let cached: Bool?
        let error: String?
    }
    
    struct RateData: Decodable {
        let provider: String
        let rate: Double
        let timestamp: String
    }
    
    struct ForexData: Decodable {
        let rate: Double
        let date: String
        let timestamp: String
    }
    
    // MARK: - Public Methods
    
    /**
     Fetch all remittance rates
     - Parameter completion: Returns Result with array of Rate objects or error
     */
    static func fetchRates(completion: @escaping (Result<[Rate]>) -> Void) {
        
        AF.request(ratesEndpoint, method: .get).responseDecodable(of: APIResponse.self) { response in
            
            switch response.result {
            case .success(let apiResponse):
                
                guard apiResponse.success, let ratesData = apiResponse.rates else {
                    completion(.Error("API returned no data"))
                    return
                }
                
                // Get forex rate for Rate objects
                let forexRateValue = apiResponse.forexRate?.rate ?? 0.0
                
                // Convert to your Rate model
                let rates = ratesData.map { rateData in
                    Rate(
                        currency: rateData.provider,
                        rate: rateData.rate,
                        dateString: getCurrentDateString(),
                        forexRate: String(format: "%.2f", forexRateValue)
                    )
                }
                
                print("✅ Fetched \(rates.count) rates from API")
                completion(.Success(rates))
                
            case .failure(let error):
                print("❌ API Error: \(error.localizedDescription)")
                completion(.Error(error.localizedDescription))
            }
        }
    }
    
    /**
     Fetch forex rate only
     - Parameter completion: Returns forex rate as Double or nil
     */
    static func fetchForexRate(completion: @escaping (Double?) -> Void) {
        
        struct ForexResponse: Decodable {
            let success: Bool
            let rate: Double?
        }
        
        AF.request(forexEndpoint, method: .get).responseDecodable(of: ForexResponse.self) { response in
            
            switch response.result {
            case .success(let forexResponse):
                if forexResponse.success, let rate = forexResponse.rate {
                    print("✅ Fetched forex rate: \(rate)")
                    completion(rate)
                } else {
                    completion(nil)
                }
                
            case .failure(let error):
                print("❌ Forex API Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    /**
     Force refresh rates (bypass cache)
     */
    static func forceRefreshRates(completion: @escaping (Result<[Rate]>) -> Void) {
        let refreshURL = "\(ratesEndpoint)?refresh=true"
        
        AF.request(refreshURL, method: .get).responseDecodable(of: APIResponse.self) { response in
            
            switch response.result {
            case .success(let apiResponse):
                guard apiResponse.success, let ratesData = apiResponse.rates else {
                    completion(.Error("API returned no data"))
                    return
                }
                
                let forexRateValue = apiResponse.forexRate?.rate ?? 0.0
                
                let rates = ratesData.map { rateData in
                    Rate(
                        currency: rateData.provider,
                        rate: rateData.rate,
                        dateString: getCurrentDateString(),
                        forexRate: String(format: "%.2f", forexRateValue)
                    )
                }
                
                print("🔄 Force refreshed \(rates.count) rates")
                completion(.Success(rates))
                
            case .failure(let error):
                print("❌ Force refresh error: \(error.localizedDescription)")
                completion(.Error(error.localizedDescription))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private static func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        return dateFormatter.string(from: Date())
    }
}

