//
//  RatesVC.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 9/6/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {
    
    let cellId = "cellId"
    public var remittanceObjects = Dictionary<String, [Remittance]>()
    public var sourceCurrency: String = "USD"
    
    lazy var rateCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(RateDiffCell.self, forCellWithReuseIdentifier: cellId)
        view.backgroundColor = UIColor(named: "background")?.withAlphaComponent(1)
        view.isScrollEnabled = true
        return view
    }()
    
    lazy var noDataLabel = MainSmallLabel(text: "You are offline or there is no data to display", textAligment: .center, numberOfLines: 2)
    
    fileprivate func setupVIew(){
        view.addSubview(rateCollection)
        rateCollection.addSubview(noDataLabel)
        
        noDataLabel.isHidden = true
        
        noDataLabel.centerXAnchor.constraint(equalTo: rateCollection.centerXAnchor).isActive = true
        noDataLabel.centerYAnchor.constraint(equalTo: rateCollection.centerYAnchor).isActive = true
        noDataLabel.leftAnchor.constraint(equalTo: rateCollection.leftAnchor).isActive = true
        noDataLabel.rightAnchor.constraint(equalTo: rateCollection.rightAnchor).isActive = true
        noDataLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        rateCollection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        rateCollection.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        rateCollection.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rateCollection.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        rateCollection.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        rateCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }
    
    fileprivate func setupNavBar(){
        let currency = Currency.currency(for: sourceCurrency) ?? Currency.default
        navigationItem.title = "History - \(currency.flag) \(currency.code)"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor:#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8041923415), .font: UIFont(name: "AppleSDGothicNeo-Light", size: 30) ?? UIFont.systemFont(ofSize: 30)]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7997634243),.font: UIFont(name: "AppleSDGothicNeo-Light", size: 20) ?? UIFont.systemFont(ofSize: 20)]
       navigationController?.navigationBar.tintColor = UIColor(named: "system")
       navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Back", style: .plain, target: self, action: #selector(backButtonAction))
    }
    
    @objc public func backButtonAction(){
        navigationController?.popViewController(animated: true)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
        setupVIew()
        setupNavBar()
        rateCollection.delegate = self
        rateCollection.dataSource = self
    }
    
}
