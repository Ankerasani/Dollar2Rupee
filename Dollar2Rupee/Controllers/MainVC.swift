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
    
    lazy var tapToEditLabel: UILabel = {
        let label = MainSmallLabel(text: "Tap amount to edit", textAligment: .center, numberOfLines: 1)
        label.isUserInteractionEnabled = false  // Don't intercept touches - pass them through to text field
        return label
    }()
    
    // Currency Selector
    lazy var currencySegmentControl: UISegmentedControl = {
        let items = Currency.allCurrencies.map { "\($0.flag) \($0.symbol)" }
        let segment = UISegmentedControl(items: items)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0 // Default to USD
        segment.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        segment.tintColor = #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)
        
        if #available(iOS 13.0, *) {
            segment.selectedSegmentTintColor = #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)
        }
        
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segment.addTarget(self, action: #selector(currencyChanged), for: .valueChanged)
        return segment
    }()
    
    let firstContainerView = ShadowView()
    lazy var dateLabel = MainSmallLabel(text: "Last update: Unknown", textAligment: .left, numberOfLines: 1)
    lazy var currentCurrencyLabel = MainSmallLabel(text: "Currenet currency: Unknown", textAligment: .right, numberOfLines: 1)
    lazy var currentCurrencyForShape = MainLabel(text: "Unknown", textAligment: .center, numberOfLines: 1)
    lazy var noDataLabel = MainSmallLabel(text: "You are offline or there is no data to display", textAligment: .center, numberOfLines: 2, font: UIFont(name: .regularFont, size: 22),backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8433098592))
    
    lazy var disclaimerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ℹ️ Independent comparison tool. We don't process transfers. Tap 'View Offer' to visit the provider's website."
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
        let currency = CurrencyManager.shared.selectedCurrency
        tf.attributedText =  "^{\(currency.symbol)}\("1.00")".superscripted(font: UIFont(name: .regularFont, size: 64) ?? UIFont.systemFont(ofSize: 42, weight: .medium))
        tf.layer.borderWidth = 0.0
        tf.keyboardType = UIKeyboardType.decimalPad
        tf.layer.borderColor = UIColor.white.cgColor.copy(alpha: 0.5)
        tf.textAlignment = .center
        tf.layer.cornerRadius = 0
        tf.addTarget(self, action: #selector(handleInput), for: .editingChanged)
        
        // Ensure text field is interactive
        tf.isUserInteractionEnabled = true
        tf.isEnabled = true
        
        // Add toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        tf.inputAccessoryView = toolbar
        
        return tf
    }()
    
    @objc func dismissKeyboard() {
        mainTextField.resignFirstResponder()
        view.endEditing(true)
    }
    
    
    @objc public func handleInput(textField:UITextField){
        let currency = CurrencyManager.shared.selectedCurrency
        
        var string = mainTextField.text!
        // Remove all currency symbols
        string = string.replacingOccurrences(of: "$", with: "")
        string = string.replacingOccurrences(of: "£", with: "")
        string = string.replacingOccurrences(of: "€", with: "")
        string = string.replacingOccurrences(of: "C$", with: "")
        string = string.replacingOccurrences(of: "A$", with: "")
        string = string.replacingOccurrences(of: "S$", with: "")
        
        string = string.currencyInputFormatting()
        if string.isEmpty {
            string = "0"
        }
        mainTextField.attributedText =  "^{\(currency.symbol)}\(string)".superscripted(font: UIFont(name: .regularFont, size: 64) ?? UIFont.systemFont(ofSize: 42, weight: .medium))
        rateCollection.reloadData()
    }
    
    @objc func currencyChanged(_ sender: UISegmentedControl) {
        print("\n🔄 ========== CURRENCY CHANGE STARTED ==========")
        print("📍 Segment index: \(sender.selectedSegmentIndex)")
        
        let selectedCurrency = Currency.allCurrencies[sender.selectedSegmentIndex]
        print("📍 Selected currency object: \(selectedCurrency.code) (\(selectedCurrency.name))")
        
        // CRITICAL: Update the manager FIRST
        CurrencyManager.shared.selectedCurrency = selectedCurrency
        
        // Verify it was saved
        let verifyCode = CurrencyManager.shared.selectedCurrency.code
        print("✅ CurrencyManager.shared.selectedCurrency.code = \(verifyCode)")
        
        if verifyCode != selectedCurrency.code {
            print("❌❌❌ CRITICAL ERROR: CurrencyManager not updated correctly! ❌❌❌")
        }
        
        print("💱 Currency changed to: \(selectedCurrency.code) (\(selectedCurrency.name))")
        print("💱 Currency symbol: \(selectedCurrency.symbol)")
        
        // Update text field symbol
        updateCurrencySymbol()
        
        // Clear existing rates
        print("🗑️  Clearing existing rates (\(self.rates.count) items)")
        self.rates = []
        self.rateCollection.reloadData()
        
        // Update forex rate for new currency
        print("📡 Calling updateForexRate()...")
        updateForexRate()
        
        // Fetch new rates for selected currency
        print("📡 Calling getRates()...")
        self.getRates { (result) in
            switch result {
            case .Success(let data):
                print("✅ Successfully loaded \(data.count) providers for \(selectedCurrency.code)")
                print("✅ First 3 rates: \(data.prefix(3).map { "\($0.currency): \($0.rate)" }.joined(separator: ", "))")
                // Save to Core Data
                CoreDataStack.saveInCoreDataWith(array: data)
                print("🔄 ========== CURRENCY CHANGE COMPLETED ==========\n")
            case .Error(let errorMessage):
                print("❌ Error loading rates for \(selectedCurrency.code): \(errorMessage)")
                print("🔄 ========== CURRENCY CHANGE FAILED ==========\n")
                DispatchQueue.main.async {
                    // Show error alert
                    let alert = UIAlertController(
                        title: "Error Loading Rates",
                        message: "Could not load rates for \(selectedCurrency.name). Please check your internet connection.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func updateCurrencySymbol() {
        let currency = CurrencyManager.shared.selectedCurrency
        var string = mainTextField.text!
        // Remove all currency symbols
        string = string.replacingOccurrences(of: "$", with: "")
        string = string.replacingOccurrences(of: "£", with: "")
        string = string.replacingOccurrences(of: "€", with: "")
        string = string.replacingOccurrences(of: "C$", with: "")
        string = string.replacingOccurrences(of: "A$", with: "")
        string = string.replacingOccurrences(of: "S$", with: "")
        
        if string.isEmpty {
            string = "1.00"
        }
        mainTextField.attributedText =  "^{\(currency.symbol)}\(string)".superscripted(font: UIFont(name: .regularFont, size: 64) ?? UIFont.systemFont(ofSize: 42, weight: .medium))
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
        
        view.addSubview(currencySegmentControl)
        view.addSubview(firstContainerView)
        view.addSubview(rateCollection)
        view.addSubview(disclaimerLabel)
        rateCollection.addSubview(noDataLabel)
        firstContainerView.addSubview(priceLabel)
        firstContainerView.addSubview(historyButton)
        firstContainerView.addSubview(mainTextField)
        firstContainerView.addSubview(tapToEditLabel)
        
        // Currency Selector Constraints
        currencySegmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        currencySegmentControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        currencySegmentControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        currencySegmentControl.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        priceLabel.leftAnchor.constraint(equalTo: firstContainerView.leftAnchor, constant: 8).isActive = true
        priceLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        priceLabel.topAnchor.constraint(equalTo: firstContainerView.topAnchor, constant: 8).isActive = true
        
        historyButton.rightAnchor.constraint(equalTo: firstContainerView.rightAnchor, constant: -8).isActive = true
        historyButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        historyButton.topAnchor.constraint(equalTo: firstContainerView.topAnchor, constant: 8).isActive = true
        
        backGroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backGroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backGroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        backGroundView.bottomAnchor.constraint(equalTo: firstContainerView.bottomAnchor, constant: 20).isActive = true
        
        noDataLabel.isHidden = true
        noDataLabel.centerXAnchor.constraint(equalTo: rateCollection.centerXAnchor, constant: 0).isActive = true
        noDataLabel.centerYAnchor.constraint(equalTo: rateCollection.centerYAnchor, constant: -80).isActive = true
        noDataLabel.leftAnchor.constraint(equalTo: rateCollection.leftAnchor, constant: 24).isActive = true
        noDataLabel.rightAnchor.constraint(equalTo: rateCollection.rightAnchor, constant: 24).isActive = true
        
        noDataLabel.heightAnchor.constraint(equalToConstant: 140).isActive = true
        
        firstContainerView.topAnchor.constraint(equalTo: currencySegmentControl.bottomAnchor, constant: 12).isActive = true
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
        
        // Set initial currency selection
        let savedCurrency = CurrencyManager.shared.selectedCurrency
        if let index = Currency.allCurrencies.firstIndex(where: { $0.code == savedCurrency.code }) {
            currencySegmentControl.selectedSegmentIndex = index
        }
        updateCurrencySymbol()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateViewLayout), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        self.updateCollectionViewData()
    }
    
    func updateCollectionViewData() {
        let currency = CurrencyManager.shared.selectedCurrency
        
        // Always fetch fresh data for the current currency instead of using cached Core Data
        // This ensures we get rates specific to the selected currency
        self.getRates { (result) in
            switch result {
            case .Success(let data):
                CoreDataStack.saveInCoreDataWith(array: data)
                print("✅ Updated collection view with \(data.count) \(currency.code) rates")
            case .Error(let errorMessage):
                print("❌ Error updating collection view: \(errorMessage)")
                
                // Fallback to Core Data if API fails
                let remittanceObjects = CoreDataStack.getCoreDataObjects()
                let currentDayObjects = CoreDataStack.checkCurrentDataObjects(objects: remittanceObjects)
                
                if currentDayObjects.count > 0 {
                    self.rates = currentDayObjects.compactMap({ Rate(currency: $0.currancy ?? "unknown", rate: $0.rate, dateString: $0.dateString ?? "", forexRate: $0.forexRate ?? "")})
                    self.rates = self.rates.sorted(by: { $0.rate > $1.rate })
                    
                    DispatchQueue.main.async {
                        self.priceLabel.attributedText = "  Forex: ^{\(currency.symbol)}\(self.rates.first?.forexRate ?? "")  ".superscripted(font: UIFont.systemFont(ofSize: 18, weight: .medium))
                        self.rateCollection.reloadData()
                    }
                    print("⚠️ Using cached Core Data rates (offline)")
                }
            }
        }
        
        // Always update forex rate for current currency
        updateForexRate()
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
