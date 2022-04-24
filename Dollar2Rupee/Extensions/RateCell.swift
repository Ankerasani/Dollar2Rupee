//
//  RateCell.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 9/6/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import UIKit

class RateCell: UICollectionViewCell {
    
    let remittanceImage = MainImageView(imageName: "")

    let doneButton    = MainButton(text: " SEND ")

    let regularRate = MainLabel(text: "", textAligment: .left, numberOfLines: 1,color: UIColor.black, font: UIFont(name: .liteFont, size: 12))
    let currencyRate = MainLabel(text: "", textAligment: .left, numberOfLines: 1,color: #colorLiteral(red: 0.4192152619, green: 0.6452817321, blue: 0.2875428498, alpha: 1))
    let resulLabel = MainLabel(text: "", textAligment: .right, numberOfLines: 1)
    
    fileprivate func setupView(){
        style(view: contentView)
        contentView.addSubview(remittanceImage)
        contentView.addSubview(regularRate)
        contentView.addSubview(currencyRate)
        contentView.addSubview(doneButton)
        doneButton.isUserInteractionEnabled = false
        
        remittanceImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        remittanceImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        remittanceImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        remittanceImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        regularRate.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        regularRate.bottomAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        regularRate.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        regularRate.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        currencyRate.topAnchor.constraint(equalTo: regularRate.bottomAnchor, constant: 3).isActive = true
        currencyRate.leftAnchor.constraint(equalTo: regularRate.leftAnchor, constant: 0).isActive = true
        
        doneButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        doneButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        doneButton.addTarget(self, action: #selector(handleSendButton), for: .allEvents)
    }
    
    @objc public func handleSendButton(){
        
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
    
    public func updateData(rate: Rate, entery: Double){
        regularRate.text = "Regular rate"
        var editableEntery = entery
        if Int(editableEntery) == 0 {
           editableEntery = 1
        }
        let roundedString = String(format: "%.2f", editableEntery * rate.rate)
        currencyRate.attributedText =  "^{₹}\(roundedString) ".superscripted(font: UIFont.systemFont(ofSize: 17, weight: .semibold))
        
        var imageName = rate.currency.replacingOccurrences(of: " ", with: "")
        if imageName == "icicimoney2india" || imageName == "icicibankmoney2India" {
            imageName = "icici"
        }
        remittanceImage.image = imageName == "" ? #imageLiteral(resourceName: "loading") : UIImage(named: imageName)
    }
    
}
