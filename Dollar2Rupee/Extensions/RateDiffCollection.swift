//
//  RateCollectionExtension.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 9/6/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import Foundation
import UIKit

extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if remittanceObjects.isEmpty {
            noDataLabel.isHidden = false
            return 0
        }else{
            noDataLabel.isHidden = true
            return remittanceObjects.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let value = Array(remittanceObjects.values)[indexPath.row]
        let key   = Array(remittanceObjects.keys)[indexPath.row]

        let detailsVC = DetailsViewCOntroller()
        detailsVC.remittanceObjects = value
        detailsVC.title = key
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = rateCollection.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! RateDiffCell
        let key   = Array(remittanceObjects.keys)[indexPath.row]
        var values = Array(remittanceObjects.values)[indexPath.row]

        values = values.sorted(by: { $0.rate > $1.rate })

        cell.updateData(dateString: key, bestRate: values.first?.rate ?? 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 40, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
}
