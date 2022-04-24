//
//  File.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 2018-01-22.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import Foundation
import UIKit


class Alert {
    
    class func showBasic(title: String, msg: String, vc: UIViewController) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "ok", style: .default , handler: nil))
        vc.present(alert, animated: true)
    }
}
