//
//  CardLabel.swift
//  Leeroy Crew
//
//  Created by Ankersani on 7/12/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import UIKit

class MainLabel: UILabel {
    
    let mainTextSize: CGFloat = 15

    init(text: String, textAligment: NSTextAlignment, numberOfLines: Int, color:UIColor? = nil, font:UIFont? = nil) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textAlignment = textAligment
        self.font = font == nil ? UIFont(name: .liteFont, size: mainTextSize) : font
        self.textColor = color == nil ? .mainTextColor : color
        self.text = text
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.5
        self.numberOfLines = numberOfLines
        self.backgroundColor = UIColor.white.withAlphaComponent(0)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


