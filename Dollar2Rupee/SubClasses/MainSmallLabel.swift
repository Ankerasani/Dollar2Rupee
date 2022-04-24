//
//  MainSmallLabel.swift
//  Leeroy Crew
//
//  Created by Ankersani on 8/19/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import UIKit

class MainSmallLabel: UILabel {

    let mainTextSize: CGFloat = 10
    
    init(text: String, textAligment: NSTextAlignment, numberOfLines: Int, font: UIFont? = UIFont(name: .regularFont, size: 14), backgroundColor: UIColor? = .white) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textAlignment = textAligment
        self.font = font
        self.textColor = backgroundColor
        self.text = text
        self.adjustsFontSizeToFitWidth = true
        //self.minimumScaleFactor = 0.5
        self.numberOfLines = numberOfLines
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
