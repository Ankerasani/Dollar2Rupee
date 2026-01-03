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

    let doneButton    = MainButton(text: "VIEW OFFER", font: UIFont.systemFont(ofSize: 11, weight: .semibold))

    let regularRate = MainLabel(text: "", textAligment: .left, numberOfLines: 1,color: UIColor.black, font: UIFont(name: .liteFont, size: 12))
    let currencyRate = MainLabel(text: "", textAligment: .left, numberOfLines: 1,color: #colorLiteral(red: 0.4192152619, green: 0.6452817321, blue: 0.2875428498, alpha: 1))
    let feeLabel = MainLabel(text: "", textAligment: .left, numberOfLines: 1, color: UIColor.darkGray, font: UIFont(name: .liteFont, size: 10))
    let deliveryLabel = MainLabel(text: "", textAligment: .right, numberOfLines: 1, color: UIColor.darkGray, font: UIFont(name: .liteFont, size: 10))
    let resulLabel = MainLabel(text: "", textAligment: .right, numberOfLines: 1)
    
    fileprivate func setupView(){
        style(view: contentView)
        contentView.addSubview(remittanceImage)
        // regularRate removed - no longer displayed
        contentView.addSubview(currencyRate)
        contentView.addSubview(feeLabel)
        contentView.addSubview(deliveryLabel)
        contentView.addSubview(doneButton)
        doneButton.isUserInteractionEnabled = false
        
        remittanceImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        remittanceImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        remittanceImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        remittanceImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        // Currency rate positioned higher (no regular rate label above it)
        currencyRate.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
        currencyRate.leftAnchor.constraint(equalTo: remittanceImage.rightAnchor, constant: 30).isActive = true
        
        feeLabel.topAnchor.constraint(equalTo: currencyRate.bottomAnchor, constant: 4).isActive = true
        feeLabel.leftAnchor.constraint(equalTo: currencyRate.leftAnchor, constant: 0).isActive = true
        feeLabel.rightAnchor.constraint(lessThanOrEqualTo: deliveryLabel.leftAnchor, constant: -4).isActive = true
        
        deliveryLabel.centerYAnchor.constraint(equalTo: feeLabel.centerYAnchor).isActive = true
        deliveryLabel.rightAnchor.constraint(equalTo: doneButton.leftAnchor, constant: -8).isActive = true
        
        doneButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        doneButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
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
        // regularRate.text removed - label hidden
        var editableEntery = entery
        if Int(editableEntery) == 0 {
           editableEntery = 1
        }
        let roundedString = String(format: "%.2f", editableEntery * rate.rate)
        // Medium font size: 20pt (between original 17 and large 24)
        currencyRate.attributedText =  "^{₹}\(roundedString) ".superscripted(font: UIFont.systemFont(ofSize: 22, weight: .semibold))
        
        // Debug: Log fee data
        print("💵 Cell Update: \(rate.currency) - Fee: $\(rate.fee), Speed: \(rate.deliverySpeed)")
        
        // Display fee with indicator - Always show it prominently
        if rate.fee == 0.0 {
            feeLabel.text = "Fee: $0 (Free ⭐)"
            feeLabel.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1) // Green for free
            feeLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold) // Slightly bigger and bold
        } else {
            feeLabel.text = String(format: "Fee: $%.2f", rate.fee)
            feeLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1) // Red for paid fees
            feeLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold) // Slightly bigger and bold
        }
        
        // Display delivery speed
        if !rate.deliverySpeed.isEmpty {
            deliveryLabel.text = rate.deliverySpeed
            deliveryLabel.textColor = UIColor.darkGray
            deliveryLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        } else {
            deliveryLabel.text = ""
        }
        
        var imageName = rate.currency.replacingOccurrences(of: " ", with: "")
        if imageName == "icicimoney2india" || imageName == "icicibankmoney2India" {
            imageName = "icici"
        }
        remittanceImage.image = imageName == "" ? #imageLiteral(resourceName: "loading") : UIImage(named: imageName)
    }
    
}
