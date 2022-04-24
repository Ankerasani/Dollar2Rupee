//
//  ActionButton.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 9/9/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import UIKit

class ActionButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        self.titleLabel?.textAlignment = .center
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Light", size: 14)
        self.layer.cornerRadius = 5
        self.tintColor = UIColor(named: "system")
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
