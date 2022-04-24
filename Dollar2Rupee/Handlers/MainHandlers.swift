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
import SwiftSoup
import SwiftyJSON

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
        
        let urlBased = ""
        guard let url = URL(string: urlBased) else {return}
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.data != nil {
                    do{
                        let json = try JSONDecoder().decode(CurrencyData.self, from: response.data!)
                        for (key, value) in json.rates {
                            if key == "INR" {
                                self.priceLabel.attributedText =  "  Forex: ^{$}\(value)  ".superscripted(font: UIFont.systemFont(ofSize: 18, weight: .medium))
                            }
                        }
                    }
                    catch{
                        print(error)
                    }
                }
            }
        
    }
    
    public func getRates(completion: @escaping (Result<[Rate]>) -> Void) {
        
        let urlBased = ""
        guard let url = URL(string: urlBased) else {return}
        
        Alamofire.request(url).responseString { response in
            if response.data != nil {
                do {
                    if let html = response.result.value {
                        self.rates.removeAll()
                        let document: Document = try SwiftSoup.parse(html)
                        let forexRate: Elements = try document.select("forex_rate")
                        
                        var rateValue = ""
                        if let rate = try? forexRate.select("forex_rate").text() {
                            rateValue = rate
                            self.priceLabel.attributedText =  "  Forex: ^{$}\(rate)  ".superscripted(font: UIFont.systemFont(ofSize: 18, weight: .medium))
                        }
                        
                        let els: Elements = try document.select("bank");
                        for element: Element in els.array() {
                            if let name = try? element.select("name").text(),
                               let rate = try? element.select("rate").text(), rate != "" {
                                
                                var updatedName = name.lowercased().replacingOccurrences(of: "(locked-in)", with: "")
                                updatedName = updatedName.lowercased().replacingOccurrences(of: " ", with: "")
                                updatedName = self.getRelativeText(text: updatedName)
                                
                                let today = Date()
                                self.rates.append(Rate(currency: updatedName, rate: Double(rate) ?? 0, dateString: today.toString(dateFormat: "dd-MMM-yyyy"), forexRate: rateValue))
                            }
                        }
                        
                        self.removeUnwantedElements()
                        self.rates = self.rates.sorted(by: { $0.rate > $1.rate })
                        DispatchQueue.main.async {
                            completion(.Success(self.rates))
                        }
                        
                        self.rateCollection.reloadData()
                    } }catch {
                        if self.rates.count == 0 {
                            //self.checkForAnotherRemittanceProviders()
                        }
                    }
            }
            if self.rates.count == 0 {
                //self.checkForAnotherRemittanceProviders()
            }
        }
    }
    
    func openBrowser (urlString: String) {
        let browserViewController = BrowserViewController()
        browserViewController.title = urlString
        browserViewController.URLToLoad = Constants.APPStoreURLs.valueByPropertyName(provider: urlString)
        browserViewController.progressTintColor = #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)
        browserViewController.trackTintColor = UIColor.darkGray
        navigationController?.pushViewController(browserViewController, animated: true)
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
