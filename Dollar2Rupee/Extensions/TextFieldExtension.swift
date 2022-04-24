//
//  TextFieldExtension.swift
//  Tax_Calculator_SE
//
//  Created by Ankersani on 15/05/2018.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import UIKit
import HandyUIKit

extension MainVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //Prevent "0" characters as the first characters. (i.e.: There should not be values like "003" "01" "000012" etc.)
        if mainTextField.text?.count == 0 && string == "0" {
            Alert.showBasic(title: "Incorrect input", msg: "First number can't be 0", vc: self)
            return false
        }
        
        //Limit the character count to 9.
        if ((mainTextField.text!) + string).count > 9 {
           // Alert.showBasic(title: "Max Length", msg: "Maximum amount of numbers in the field is 6", vc: self)
            return false
        }
        
        //Have a decimal keypad. Which means user will be able to enter Double values. (Needless to say "." will be limited one)
        if (mainTextField.text?.contains("."))! && string == "." {
            Alert.showBasic(title: "Incorrect input", msg: "Please check the field", vc: self)
            return false
        }

        
        //Only allow numbers. No Copy-Paste text values.
        let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789.$")
        let textCharacterSet = CharacterSet.init(charactersIn: mainTextField.text! + string)
        if !allowedCharacterSet.isSuperset(of: textCharacterSet) {
            return false
        }

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
       // formatter.numberStyle = .currencyAccounting
        //formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
}
