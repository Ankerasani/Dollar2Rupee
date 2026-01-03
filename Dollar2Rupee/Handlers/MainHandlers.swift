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
        APIService.fetchForexRate { forexRate in
            guard let rate = forexRate else {
                print("❌ Failed to fetch forex rate")
                return
            }
            
            DispatchQueue.main.async {
                self.priceLabel.attributedText = "  Forex: ^{$}\(String(format: "%.2f", rate))  ".superscripted(font: UIFont.systemFont(ofSize: 18, weight: .medium))
            }
        }
    }
    
    public func getRates(completion: @escaping (Result<[Rate]>) -> Void) {
        APIService.fetchRates { result in
            switch result {
            case .Success(let rates):
                self.rates = rates
                
                // Filter unwanted elements
                self.removeUnwantedElements()
                
                // Sort by rate (highest first)
                self.rates = self.rates.sorted(by: { $0.rate > $1.rate })
                
                print("✅ Successfully processed \(self.rates.count) rates")
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    self.rateCollection.reloadData()
                    completion(.Success(self.rates))
                }
                
            case .Error(let errorMessage):
                print("❌ Error fetching rates: \(errorMessage)")
                DispatchQueue.main.async {
                    completion(.Error(errorMessage))
                }
            }
        }
    }
    
    func openBrowser (urlString: String) {
        // Get the provider URL
        let providerURL = Constants.APPStoreURLs.valueByPropertyName(provider: urlString)
        
        // Check if URL is empty
        guard !providerURL.isEmpty, let url = URL(string: providerURL) else {
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
        
        // Try to open the provider's app if installed (for deep links like "xoom://")
        if url.scheme != "http" && url.scheme != "https" {
            if UIApplication.shared.canOpenURL(url) {
                // Open in the provider's installed app
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // App not installed, show alert
                let alert = UIAlertController(
                    title: "App Not Installed",
                    message: "\(urlString) app is not installed. Would you like to visit the App Store?",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "App Store", style: .default) { _ in
                    // You'll need to add actual App Store URLs to your Constants
                    if let appStoreURL = URL(string: providerURL) {
                        UIApplication.shared.open(appStoreURL, options: [:])
                    }
                })
                present(alert, animated: true)
            }
        } else {
            // Open in Safari View Controller (in-app Safari with visible controls)
            let safariVC = SFSafariViewController(url: url)
            safariVC.preferredControlTintColor = #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)
            safariVC.dismissButtonStyle = .close
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    func getAPPInstallationInformation (urlString: String) {
        
        var constructedURLString = ""
        if urlString == "icicimoney2india" || urlString == "icicibankmoney2India" {
            self.openURL(urlString: Constants.APPStoreURLs.icici)
            return
        } else if urlString == "remitmoney" {
            self.openURL(urlString: Constants.APPStoreURLs.remitmoney)
            return
        }
        
        constructedURLString = Constants.appStoreURL(appID:Constants.APPStoreURLs.valueByPropertyName(provider: urlString))
        
        if let url = URL(string: "\(urlString)://"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            self.openURL(urlString: constructedURLString)
        }
    }
    
    func openURL(urlString: String) {
        if let itunesUrl = URL(string: urlString) , UIApplication.shared.canOpenURL(itunesUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(itunesUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(itunesUrl)
            }
        }
    }
}




enum Result<T> {
    case Success(T)
    case Error(String)
}
