//
//  DetailsViewControllerCollection.swift
//  Dollar2Rupee
//
//  Created by Ankerasani on 4/6/19.
//  Copyright © 2019 Ankersani. All rights reserved.
//

import Foundation

import UIKit

extension DetailsViewCOntroller: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if remittanceObjects.isEmpty {
            return 0
        }else{
            return remittanceObjects.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = rateCollection.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DetailsRateCell
        let rates = remittanceObjects.compactMap({ Rate(currency: $0.currancy ?? "unknown", rate: $0.rate, dateString: $0.dateString ?? "", forexRate: $0.forexRate ?? "", sourceCurrency: $0.sourceCurrency ?? "USD")})
        cell.updateData(rate: rates[indexPath.row], entery: 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 68, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
}
