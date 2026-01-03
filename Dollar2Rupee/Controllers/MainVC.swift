//
//  MainVC.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 8/28/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import UIKit
import Pastel
import CoreData

class MainVC: UIViewController {
    let remittanceArray = ["remit2india", "xoom", "ria", "remitmoney", "instarem","transferwise","remitly","transfast","ofx","statebank","westernunion"]
    
    let cellId = "cellId"
    var rates = [Rate]()
    var forexRate = Rate(currency: "", rate: 0.0, dateString: "", forexRate: "")
    var filtredResults = [Rate]()
    var currenntCurrency: String = "USD"
    let menuCellId = "menuCellId"
    var menuShowing = true
    var heightAnchor: NSLayoutConstraint?
    var menuList = [Menu]()
    let historyButton = MainButton(text: "History  ", font: UIFont(name: .regularFont, size: 18), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), backGroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0))

    
    lazy var gradientView: PastelView = {
        let view = PastelView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 380))
        view.startPastelPoint = .bottomLeft
        view.endPastelPoint = .topRight
        view.animationDuration = 2.6
        
        view.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                        UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                        UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                        UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                        UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                        #colorLiteral(red: 0.9411764706, green: 0.1843137255, blue: 0.7607843137, alpha: 1),#colorLiteral(red: 0.3568627451, green: 0.1411764706, blue: 0.4784313725, alpha: 1),#colorLiteral(red: 0.9882352941, green: 0.8901960784, blue: 0.5411764706, alpha: 1),#colorLiteral(red: 0.9529411765, green: 0.5058823529, blue: 0.5058823529, alpha: 1),#colorLiteral(red: 0.09411764706, green: 0.3058823529, blue: 0.4078431373, alpha: 1),#colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)])
        
        view.startAnimation()
        return view
    }()
    
    
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view.clipsToBounds = true
        view.layer.cornerRadius = 2
        return view
    }()
    
    lazy var titleLabel = MainLabel(text: "Dollar2Rupee", textAligment: .left, numberOfLines: 1, color: UIColor.white, font: UIFont(name: .regularFont, size: 40))
    lazy var priceLabel = MainLabel(text: "  Forex rate: $0.00  ", textAligment: .left, numberOfLines: 1, color: #colorLiteral(red: 0.9405078292, green: 0.9449090958, blue: 0.9665934443, alpha: 1), font: UIFont(name: .regularFont, size: 18))
    
    lazy var menuGlassView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view.clipsToBounds = true
        view.layer.cornerRadius = 2
        return view
    }()
    
    lazy var menuTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: menuCellId)
        table.backgroundColor = UIColor.white.withAlphaComponent(0)
        table.separatorStyle = .none
        return table
    }()
    
    lazy var rateCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(RateCell.self, forCellWithReuseIdentifier: cellId)
        view.backgroundColor = UIColor(named: "background")?.withAlphaComponent(1)
        view.isScrollEnabled = true
        return view
    }()
    
    lazy var tapToEditLabel = MainSmallLabel(text: "Tap amount to edit", textAligment: .center, numberOfLines: 1)
    
    let firstContainerView = ShadowView()
    lazy var dateLabel = MainSmallLabel(text: "Last update: Unknown", textAligment: .left, numberOfLines: 1)
    lazy var currentCurrencyLabel = MainSmallLabel(text: "Currenet currency: Unknown", textAligment: .right, numberOfLines: 1)
    lazy var currentCurrencyForShape = MainLabel(text: "Unknown", textAligment: .center, numberOfLines: 1)
    lazy var noDataLabel = MainSmallLabel(text: "You are offline or there is no data to display", textAligment: .center, numberOfLines: 2, font: UIFont(name: .regularFont, size: 22),backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8433098592))
    
    lazy var disclaimerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ℹ️ Dollar2Rupee is an independent comparison tool. We don't process transfers. Tap 'View Offer' to visit the provider's website."
        label.font = UIFont(name: .liteFont, size: 11)
        label.textColor = UIColor.darkGray.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var mainTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = UIColor.white
        tf.attributedText =  "^{$}\("1.00")".superscripted(font: UIFont(name: .regularFont, size: 64) ?? UIFont.systemFont(ofSize: 42, weight: .medium))
        tf.layer.borderWidth = 0.0
        tf.keyboardType = UIKeyboardType.decimalPad
        tf.layer.borderColor = UIColor.white.cgColor.copy(alpha: 0.5)
        tf.textAlignment = .center
        tf.layer.cornerRadius = 0
        tf.addTarget(self, action: #selector(handleInput), for: .editingChanged)
        return tf
    }()
    
    
    @objc public func handleInput(textField:UITextField){
        
        var string = mainTextField.text!
        string = string.replacingOccurrences(of: "$", with: "")
        
        string = string.currencyInputFormatting()
        if string.isEmpty {
            string = "0"
        }
        mainTextField.attributedText =  "^{$}\(string)".superscripted(font: UIFont(name: .regularFont, size: 64) ?? UIFont.systemFont(ofSize: 42, weight: .medium))
        rateCollection.reloadData()
    }
    
    
    fileprivate func setupView(){
        
        backGroundView.backgroundColor = UIColor.white
        view.addSubview(backGroundView)
        backGroundView.insertSubview(gradientView, at: 0)
        
        priceLabel.textColor = .white
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.backgroundColor = .clear
        priceLabel.clipsToBounds = true
        priceLabel.layer.cornerRadius = 12
        
        historyButton.titleLabel?.textAlignment = .left
        
        view.addSubview(firstContainerView)
        view.addSubview(rateCollection)
        view.addSubview(disclaimerLabel)
        rateCollection.addSubview(noDataLabel)
        firstContainerView.addSubview(priceLabel)
        firstContainerView.addSubview(historyButton)
        firstContainerView.addSubview(mainTextField)
        firstContainerView.addSubview(tapToEditLabel)
        
        priceLabel.leftAnchor.constraint(equalTo: firstContainerView.leftAnchor, constant: 8).isActive = true
        priceLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        priceLabel.topAnchor.constraint(equalTo: firstContainerView.topAnchor, constant: 8).isActive = true
        
        historyButton.rightAnchor.constraint(equalTo: firstContainerView.rightAnchor, constant: -8).isActive = true
        historyButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        historyButton.topAnchor.constraint(equalTo: firstContainerView.topAnchor, constant: 8).isActive = true
        
        backGroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backGroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backGroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        backGroundView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        noDataLabel.isHidden = true
        noDataLabel.centerXAnchor.constraint(equalTo: rateCollection.centerXAnchor, constant: 0).isActive = true
        noDataLabel.centerYAnchor.constraint(equalTo: rateCollection.centerYAnchor, constant: -80).isActive = true
        noDataLabel.leftAnchor.constraint(equalTo: rateCollection.leftAnchor, constant: 24).isActive = true
        noDataLabel.rightAnchor.constraint(equalTo: rateCollection.rightAnchor, constant: 24).isActive = true
        
        noDataLabel.heightAnchor.constraint(equalToConstant: 140).isActive = true
        
        firstContainerView.topAnchor.constraint(equalTo: view.topAnchor,constant: 40).isActive = true
        firstContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        firstContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        firstContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        
        mainTextField.topAnchor.constraint(equalTo: firstContainerView.topAnchor,constant: 50).isActive = true
        mainTextField.leftAnchor.constraint(equalTo: firstContainerView.leftAnchor,constant: 10).isActive = true
        mainTextField.rightAnchor.constraint(equalTo: firstContainerView.rightAnchor,constant: -10).isActive = true
        mainTextField.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        tapToEditLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        tapToEditLabel.centerXAnchor.constraint(equalTo: mainTextField.centerXAnchor).isActive = true
        tapToEditLabel.bottomAnchor.constraint(equalTo: mainTextField.bottomAnchor, constant: 30).isActive = true
        
        rateCollection.topAnchor.constraint(equalTo: firstContainerView.bottomAnchor,constant: 8).isActive = true
        rateCollection.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rateCollection.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        rateCollection.bottomAnchor.constraint(equalTo: disclaimerLabel.topAnchor, constant: -8).isActive = true
        rateCollection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        disclaimerLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        disclaimerLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        disclaimerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        disclaimerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        
        historyButton.addTarget(self, action: #selector(showHistory), for: .touchUpInside)
        
    }
    
    @objc fileprivate func showHistory() {
        let historyVC = HistoryViewController()
        historyVC.remittanceObjects = CoreDataStack.getCoreDataObjects()
        //  let navigationVC = UINavigationController(rootViewController: historyVC)
        //  navigationVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        // navigationVC.navigationBar.backItem?.title = "Back"
        //  present(navigationVC, animated: true, completion: nil)
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.updateViewLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
        setupView()
        
        rateCollection.delegate = self
        rateCollection.dataSource = self
        menuTable.delegate = self
        menuTable.dataSource = self
        mainTextField.delegate = self
        mainTextField.returnKeyType = UIReturnKeyType.done
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateViewLayout), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        self.updateCollectionViewData()
    }
    
    func updateCollectionViewData() {
        
        let remittanceObjects = CoreDataStack.getCoreDataObjects()
        let currentDayObjects = CoreDataStack.checkCurrentDataObjects(objects: remittanceObjects)
        
        if currentDayObjects.count > 0 {
            self.rates = currentDayObjects.compactMap({ Rate(currency: $0.currancy ?? "unknown", rate: $0.rate, dateString: $0.dateString ?? "", forexRate: $0.forexRate ?? "")})
            
            self.rates = self.rates.sorted(by: { $0.rate > $1.rate })
            
            self.priceLabel.attributedText =  "  Forex: ^{$}\(self.rates.first?.forexRate ?? "")  ".superscripted(font: UIFont.systemFont(ofSize: 18, weight: .medium))
            
            if self.priceLabel.text?.count ?? 0 <= 0 {
                updateForexRate()
            }
            
            self.rateCollection.reloadData()
            return
        }
        
        self.getRates { (result) in
            switch result {
            case .Success(let data):
                CoreDataStack.saveInCoreDataWith(array: data)
            case .Error(_):
                DispatchQueue.main.async {
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateViewLayout(){
        self.gradientView.startAnimation()
    }
    
    override func touchesBegan(_: Set<UITouch>, with: UIEvent?) {
        self.mainTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
}
