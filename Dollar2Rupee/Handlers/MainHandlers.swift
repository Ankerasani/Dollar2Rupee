//
//  MainHandlers.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 8/28/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SafariServices

extension MainVC {
    
    @objc public func handleMenu(){
        if (menuShowing){
            UIView.animate(withDuration: 0.3) {
                self.heightAnchor?.isActive = false
                self.heightAnchor = self.menuGlassView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                self.heightAnchor?.isActive = true
                self.view.layoutIfNeeded()
            }
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.heightAnchor?.isActive = false
                self.heightAnchor = self.menuGlassView.bottomAnchor.constraint(equalTo: self.view.topAnchor)
                self.heightAnchor?.isActive = true
                self.view.layoutIfNeeded()
            }) { (true) in
            }
        }
        menuShowing = !menuShowing
    }
    
    @objc public func finishedWithInput (){
        view.endEditing(true)
    }
    
    @objc public func handleUpdate(){
        updateForexRate()
    }
    
    func removeUnwantedElements() {
        self.rates = self.rates.filter { remittanceArray.contains($0.currency) }
    }
    
    
    
    func getRelativeText(text: String) -> String {
        
        var updatedName = text
        
        if updatedName == "icicimoney2india" || updatedName == "icicibankmoney2India" {
            updatedName = "icici"
        }
        
        if updatedName == "instaremptelimited" {
            updatedName = "instarem"
        }
        
        if updatedName == "riamoneytransfer" {
            updatedName = "ria"
        }
        
        if updatedName == "sbicalifornia" {
            updatedName = "statebank"
        }
        
        return updatedName
    }
    
    public func updateForexRate() {
        let currency = CurrencyManager.shared.selectedCurrency
        print("  📍 updateForexRate() - CurrencyManager currency: \(currency.code)")
        
        APIService.fetchForexRate(currency: currency.code) { forexRate in
            guard let rate = forexRate else {
                print("  ❌ Failed to fetch forex rate for \(currency.code)")
                return
            }
            
            print("  ✅ Fetched forex rate: \(rate) for \(currency.code)")
            
            DispatchQueue.main.async {
                let labelText = "  Forex: ^{\(currency.symbol)}\(String(format: "%.2f", rate))  "
                print("  📝 Setting priceLabel to: \(labelText.replacingOccurrences(of: "^{", with: "").replacingOccurrences(of: "}", with: ""))")
                self.priceLabel.attributedText = labelText.superscripted(font: UIFont.systemFont(ofSize: 18, weight: .medium))
            }
        }
    }
    
    public func getRates(completion: @escaping (Result<[Rate]>) -> Void) {
        let currency = CurrencyManager.shared.selectedCurrency
        print("  📍 getRates() - CurrencyManager currency: \(currency.code)")
        
        APIService.fetchRates(currency: currency.code) { result in
            switch result {
            case .Success(let rates):
                print("  ✅ APIService returned \(rates.count) rates for \(currency.code)")
                if rates.count > 0 {
                    print("  📊 First rate: \(rates[0].currency) = \(rates[0].rate)")
                }
                
                self.rates = rates
                
                // Filter unwanted elements
                self.removeUnwantedElements()
                
                // Sort by rate (highest first)
                self.rates = self.rates.sorted(by: { $0.rate > $1.rate })
                
                print("  ✅ Successfully processed \(self.rates.count) rates for \(currency.code)")
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    print("  🔄 Calling rateCollection.reloadData()")
                    self.rateCollection.reloadData()
                    completion(.Success(self.rates))
                }
                
            case .Error(let errorMessage):
                print("  ❌ Error fetching rates for \(currency.code): \(errorMessage)")
                DispatchQueue.main.async {
                    completion(.Error(errorMessage))
                }
            }
        }
    }
    
    func openBrowser (urlString: String) {
        // Get the provider website URL
        let providerURL = Constants.APPStoreURLs.valueByPropertyName(provider: urlString)
        
        // Check if URL is empty
        guard !providerURL.isEmpty else {
            // Show alert that provider link is not available
            let alert = UIAlertController(
                title: "Link Not Available",
                message: "Sorry, we don't have a direct link for \(urlString) at this time. Please visit their website directly.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Get the deep link URL scheme for the provider (if available)
        let deepLinkURL = Constants.APPDeepLinks.valueByPropertyName(provider: urlString)
        
        // First, try to open the provider's app using deep link (if available)
        if !deepLinkURL.isEmpty, let appURL = URL(string: deepLinkURL) {
            if UIApplication.shared.canOpenURL(appURL) {
                // App is installed, open it directly
                print("✅ Opening \(urlString) app with deep link: \(deepLinkURL)")
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                return
            }
        }
        
        // App not installed or no deep link available, open website in Safari View Controller
        guard let url = URL(string: providerURL) else {
            print("❌ Invalid URL: \(providerURL)")
            return
        }
        
        print("🌐 Opening \(urlString) website: \(providerURL)")
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)
        safariVC.dismissButtonStyle = .close
        present(safariVC, animated: true, completion: nil)
    }
}




enum Result<T> {
    case Success(T)
    case Error(String)
}
