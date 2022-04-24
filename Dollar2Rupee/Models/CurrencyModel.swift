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
    
    init(currency: String, rate: Double, dateString: String, forexRate: String) {
        self.currency = currency
        self.rate = rate
        self.dateString = dateString
        self.forexRate = forexRate
    }
}


