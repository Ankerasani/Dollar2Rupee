//
//  CurrencyModel.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 9/3/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import Foundation
import UIKit

class CurrencyData: Decodable {
    let base: String
    let date: String
    let rates: [String: Double]
    
    init(base: String, date: String, rates: [String: Double]) {
        self.base = base
        self.date = date
        self.rates = rates
    }
}

class Rate {
    let currency: String
    let rate: Double
    let dateString: String
    let forexRate: String
    let sourceCurrency: String
    let fee: Double
    let markup: Double
    let deliverySpeed: String
    
    init(currency: String, rate: Double, dateString: String, forexRate: String, sourceCurrency: String = "USD", fee: Double = 0.0, markup: Double = 0.0, deliverySpeed: String = "") {
        self.currency = currency
        self.rate = rate
        self.dateString = dateString
        self.forexRate = forexRate
        self.sourceCurrency = sourceCurrency
        self.fee = fee
        self.markup = markup
        self.deliverySpeed = deliverySpeed
    }
}


