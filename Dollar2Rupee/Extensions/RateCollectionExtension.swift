//
//  RateCollectionExtension.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 9/6/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import Foundation
import UIKit

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if rates.isEmpty {
                noDataLabel.isHidden = false
                return 0
            }else{
                noDataLabel.isHidden = true
                return rates.count
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let rate = rates[indexPath.row]
            let cell  = rateCollection.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! RateCell
        
        if (mainTextField.text?.isEmpty)! {
            cell.updateData(rate: rate, entery: 0)
        }else{
            var string = mainTextField.text!
            string = string.replacingOccurrences(of: "$", with: "")
            cell.updateData(rate: rate, entery: Double(string) ?? 0)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rate = rates[indexPath.row]
        let currency = rate.currency.replacingOccurrences(of: " ", with: "")
        self.openBrowser(urlString: currency)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: view.frame.width - 40, height: 64)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    
}
