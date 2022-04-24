//
//  RateCell.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 9/6/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import UIKit

class RateDiffCell: UICollectionViewCell {
    
    let accsessoryImage = MainImageView(imageName: "accessoryIcon", tintColor:#colorLiteral(red: 0.4392156863, green: 0.5019607843, blue: 0.5647058824, alpha: 0.7178147007))

    lazy var currencyName = MainLabel(text: "", textAligment: .center, numberOfLines: 1, color: UIColor.black, font: UIFont(name: .regularFont, size: 22))
    
    lazy var bestRateLabel = MainLabel(text: "", textAligment: .center, numberOfLines: 1, color: #colorLiteral(red: 0.4192152619, green: 0.6452817321, blue: 0.2875428498, alpha: 1), font: UIFont(name: .boldFont, size: 18))

    
    fileprivate func setupView(){
        style(view: contentView)
        contentView.addSubview(currencyName)
        contentView.addSubview(bestRateLabel)
        contentView.addSubview(accsessoryImage)

        currencyName.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        currencyName.heightAnchor.constraint(equalToConstant: 40).isActive = true
        currencyName.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 24).isActive = true
        
        bestRateLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -54).isActive = true
        bestRateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        bestRateLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        accsessoryImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        accsessoryImage.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        accsessoryImage.heightAnchor.constraint(equalToConstant: 36).isActive = true
        accsessoryImage.widthAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func style(view: UIView) {
        view.layer.masksToBounds = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 1, height: 5)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.2
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 14, height: 14)).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    public func updateData(dateString: String, bestRate: Double){
        currencyName.text = dateString
        bestRateLabel.attributedText =  "^{$}\(bestRate)".superscripted(font: UIFont(name: .boldFont, size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium))
    }
    
}
