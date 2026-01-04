//
//  ShadowView.swift
//  Leeroy Crew
//
//  Created by Ankersani on 9/5/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.masksToBounds = false
        self.backgroundColor = .clear
        self.layer.cornerRadius = 14
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 5)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.15
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
