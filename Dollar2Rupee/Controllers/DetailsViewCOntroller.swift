//
//  DetailsViewCOntroller.swift
//  Dollar2Rupee
//
//  Created by Ankerasani on 4/6/19.
//  Copyright © 2019 Ankersani. All rights reserved.
//

import Foundation
import UIKit

class DetailsViewCOntroller: UIViewController {
    
    let cellId = "cellId"
    var currenntCurrency: String = "USD"
    let menuCellId = "menuCellId"
     var remittanceObjects = [Remittance]()
    
    lazy var rateCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(DetailsRateCell.self, forCellWithReuseIdentifier: cellId)
        view.backgroundColor = UIColor(named: "background")?.withAlphaComponent(1)
        view.isScrollEnabled = true
        return view
    }()

    fileprivate func setupView(){
        view.addSubview(rateCollection)
        rateCollection.topAnchor.constraint(equalTo: view.topAnchor,constant: 8).isActive = true
        rateCollection.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rateCollection.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        rateCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: 1).isActive = true
        rateCollection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupView()
        self.navigationController?.navigationBar.isHidden = false
        setupNavBar()
        self.rateCollection.delegate = self
        self.rateCollection.dataSource = self
    }
    
    fileprivate func setupNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor:#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8041923415), .font: UIFont(name: "AppleSDGothicNeo-Light", size: 30) ?? UIFont.systemFont(ofSize: 30)]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7997634243),.font: UIFont(name: "AppleSDGothicNeo-Light", size: 20) ?? UIFont.systemFont(ofSize: 20)]
        navigationController?.navigationBar.tintColor = UIColor(named: "system")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Back", style: .plain, target: self, action: #selector(backButtonAction))
    }
    
    @objc public func backButtonAction(){
        navigationController?.popViewController(animated: true)
    }

}
