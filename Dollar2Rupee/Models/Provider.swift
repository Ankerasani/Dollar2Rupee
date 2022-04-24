//
//  Provider.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 2/16/19.
//  Copyright © 2019 Ankersani. All rights reserved.
//

import Foundation

struct Provider {
    let name: String
    let logo: String
    let firstTimeRate: String
    let regularRate: String

    init(name: String, logo: String, firstTimeRate: String, regularRate: String) {
        self.name = name
        self.logo = logo
        self.firstTimeRate = firstTimeRate
        self.regularRate = regularRate
    }
}
