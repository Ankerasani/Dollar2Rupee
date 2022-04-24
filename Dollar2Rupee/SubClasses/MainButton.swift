//
//  ActionButton.swift
//  Leeroy Crew
//
//  Created by Ankersani on 7/17/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import UIKit

class MainButton: UIButton {

    init(text: String, font: UIFont? = UIFont.systemFont(ofSize: 13, weight: .semibold), textColor: UIColor? = #colorLiteral(red: 0.2805711627, green: 0.6057628989, blue: 0.9850562215, alpha: 1) , backGroundColor: UIColor? = #colorLiteral(red: 0.9413561225, green: 0.9408261776, blue: 0.9625979066, alpha: 1)) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        self.setTitle(text, for: .normal)
        self.titleLabel?.textAlignment = .center
        self.setTitleColor(textColor, for: .normal)
        self.titleLabel?.font = font
        self.layer.cornerRadius = 15
        self.backgroundColor = backGroundColor
        self.tintColor = backGroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
