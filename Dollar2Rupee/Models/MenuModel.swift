//
//  MenuModel.swift
//  IOCode
//
//  Created by Ankersani on 8/2/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import Foundation
import UIKit

class Menu {
    var title: String?
    var vc: UIViewController?
    
    init(title: String, vc: UIViewController) {
        self.title = title
        self.vc = vc
    }
}
