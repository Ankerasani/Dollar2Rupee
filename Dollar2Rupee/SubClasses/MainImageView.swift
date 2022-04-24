//
//  MainImageView.swift
//  Leeroy Crew
//
//  Created by Ankersani on 7/25/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import UIKit

class MainImageView: UIImageView {

    init(imageName: String, tintColor: UIColor? = UIColor(named: "system")) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        self.contentMode = .scaleAspectFit
        self.clipsToBounds = true
        self.tintColor = tintColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
