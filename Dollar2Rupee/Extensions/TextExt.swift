//
//  TextExt.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 8/28/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    //fonts
    static let liteFont = "HelveticaNeue-Light"
    static let regularFont = "HelveticaNeue"
    static let boldFont = "HelveticaNeue-Bold"

    
    //main screen
    static let titleText = "Dollar2Rupee"

    static let titleRates = "History"
    
}


extension CGFloat {
    static let mainTextSize = CGFloat(15.0)
}


extension String {
    var url: URL? {
        var queryCharacterSet = CharacterSet.urlQueryAllowed
        queryCharacterSet.insert(charactersIn: "#")
        let whiteSpaceCharacterSet = CharacterSet.whitespacesAndNewlines
        
        let trimmed = self.trimmingCharacters(in: whiteSpaceCharacterSet)
        
        if trimmed.contains("%20") {
            return URL(string: trimmed)
        }
        
        if let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: queryCharacterSet) {
            return URL(string: encoded)
        }
        return nil
    }
}
