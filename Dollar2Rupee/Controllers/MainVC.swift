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
    var forexRate = Rate(currency: "", rate: 0.0, dateString: "", forexRate: "", sourceCurrency: "USD")
    var filtredResults = [Rate]()
    var currenntCurrency: String = "USD"
    var currentDestinationCurrency: String = "INR" // Track destination currency
    let menuCellId = "menuCellId"
    var menuShowing = true
    var heightAnchor: NSLayoutConstraint?
    var menuList = [Menu]()
    let historyButton = MainButton(text: "History  ", font: UIFont(name: .regularFont, size: 18), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), backGroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0))
    let rateAlertButton = MainButton(text: "🔔", font: UIFont.systemFont(ofSize: 22), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), backGroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0))
    
    lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Use SF Symbol for settings (better than emoji)
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
            let image = UIImage(systemName: "gearshape", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = .white
        } else {
            button.setTitle("⚙️", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        }
        
        button.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
        return button
    }()

    
    lazy var gradientView: PastelView = {
        let view = PastelView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 380))
        view.startPastelPoint = .bottomLeft
        view.endPastelPoint = .topRight
        view.animationDuration = 3.5
        
        view.setColors([UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 1.0),
                        UIColor(red: 168/255, green: 85/255, blue: 247/255, alpha: 1.0),
                        UIColor(red: 236/255, green: 72/255, blue: 153/255, alpha: 1.0),
                        UIColor(red: 251/255, green: 146/255, blue: 60/255, alpha: 1.0),
                        #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1),
                        UIColor(red: 14/255, green: 165/255, blue: 233/255, alpha: 1.0)])
        
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
        let currency = CurrencyManager.shared.selectedCurrency
        let label = MainSmallLabel(text: "Amount in \(currency.flag) \(currency.code) to send", textAligment: .center, numberOfLines: 1)
        label.isUserInteractionEnabled = false  // Don't intercept touches - pass them through to text field
        return label
    }()
    
    // MARK: - Side-by-Side Currency Selectors
    
    lazy var currencyContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.98)
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.15
        return view
    }()
    
    lazy var fromLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "FROM"
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = UIColor.systemGray
        return label
    }()
    
    lazy var toLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "TO"
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = UIColor.systemGray
        return label
    }()
    
    lazy var fromCurrencyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 0.12)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(#colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(showSourceCurrencyPicker), for: .touchUpInside)
        
        let currency = CurrencyManager.shared.selectedCurrency
        button.setTitle("\(currency.flag) \(currency.code) ▼", for: .normal)
        
        return button
    }()
    
    lazy var toCurrencyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.1843137255, blue: 0.7607843137, alpha: 0.12)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = #colorLiteral(red: 0.9411764706, green: 0.1843137255, blue: 0.7607843137, alpha: 1)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(#colorLiteral(red: 0.9411764706, green: 0.1843137255, blue: 0.7607843137, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(showDestinationCurrencyPicker), for: .touchUpInside)
        
        let destination = DestinationCurrency.allDestinations[0]
        button.setTitle("\(destination.flag) \(destination.code) ▼", for: .normal)
        
        return button
    }()
    
    lazy var arrowLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "→"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.systemGray2
        return label
    }()
    
    // Keep old controls hidden for backward compatibility
    // Source Currency Selector
    lazy var currencySegmentControl: UISegmentedControl = {
        let items = Currency.allCurrencies.map { "\($0.flag) \($0.symbol)" }
        let segment = UISegmentedControl(items: items)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0 // Default to USD
        segment.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        segment.tintColor = #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)
        segment.isHidden = true // Hide old control
        
        if #available(iOS 13.0, *) {
            segment.selectedSegmentTintColor = #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)
        }
        
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segment.addTarget(self, action: #selector(currencyChanged), for: .valueChanged)
        return segment
    }()
    
    // Destination Currency Label
    lazy var sendingToLabel = MainSmallLabel(text: "Sending to", textAligment: .center, numberOfLines: 1)
    
    // Destination Currency Selector
    lazy var destinationSegmentControl: UISegmentedControl = {
        let items = DestinationCurrency.allDestinations.map { "\($0.flag) \($0.code)" }
        let segment = UISegmentedControl(items: items)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0 // Default to INR (India)
        segment.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        segment.tintColor = #colorLiteral(red: 0.9411764706, green: 0.1843137255, blue: 0.7607843137, alpha: 1)
        segment.isHidden = true // Hide old control
        
        if #available(iOS 13.0, *) {
            segment.selectedSegmentTintColor = #colorLiteral(red: 0.9411764706, green: 0.1843137255, blue: 0.7607843137, alpha: 1)
        }
        
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segment.addTarget(self, action: #selector(destinationChanged), for: .valueChanged)
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
        label.text = "ℹ️ We compare rates, not process transfers. Rates shown are estimates and may differ from actual provider rates. Always verify on provider website before sending."
        label.font = UIFont(name: .regularFont, size: 14)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        //label.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
       // label.layer.cornerRadius = 10
        //label.clipsToBounds = true
       // label.layer.borderWidth = 1
        //label.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        return label
    }()
    
    lazy var mainTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = UIColor.white
        tf.text = "1000"  // Start with plain text
        tf.layer.borderWidth = 0.0
        tf.keyboardType = UIKeyboardType.numberPad  // Changed to numberPad for better UX
        tf.layer.borderColor = UIColor.white.cgColor.copy(alpha: 0.5)
        tf.textAlignment = .center
        tf.layer.cornerRadius = 0
        tf.font = UIFont(name: .regularFont, size: 64) ?? UIFont.systemFont(ofSize: 42, weight: .medium)
        
        // Ensure text field is interactive and selectable
        tf.isUserInteractionEnabled = true
        tf.isEnabled = true
        
        // Make text selectable
        tf.clearButtonMode = .whileEditing
        
        // Add toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        tf.inputAccessoryView = toolbar
        
        // Add target for immediate updates
        tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        return tf
    }()
    
    @objc func dismissKeyboard() {
        mainTextField.resignFirstResponder()
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Get the raw text (numbers only)
        guard var text = textField.text else { return }
        
        // Remove any non-numeric characters except decimal point
        text = text.filter { "0123456789.".contains($0) }
        
        // Prevent multiple decimal points
        let components = text.components(separatedBy: ".")
        if components.count > 2 {
            text = components[0] + "." + components[1...].joined()
        }
        
        // Limit to 2 decimal places
        if let decimalIndex = text.firstIndex(of: ".") {
            let afterDecimal = text[text.index(after: decimalIndex)...]
            if afterDecimal.count > 2 {
                let endIndex = text.index(decimalIndex, offsetBy: 3)
                text = String(text[..<endIndex])
            }
        }
        
        // Update the text field
        textField.text = text
        
        // Trigger rate recalculation
        rateCollection.reloadData()
    }
    
    // Legacy function - kept for compatibility but now uses textFieldDidChange
    @objc public func handleInput(textField:UITextField){
        textFieldDidChange(textField)
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
        
        // Update the label to show current currency
        tapToEditLabel.text = "Amount in \(selectedCurrency.flag) \(selectedCurrency.code) to send"
        
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
        // Just keep the current numeric value, no need to change it
        // The currency symbol is now shown in the placeholder or label
        if mainTextField.text == nil || mainTextField.text!.isEmpty {
            mainTextField.text = "1000"
        }
    }
    
    @objc func destinationChanged(_ sender: UISegmentedControl) {
        print("\n🌍 ========== DESTINATION CHANGE STARTED ==========")
        print("📍 Segment index: \(sender.selectedSegmentIndex)")
        
        let selectedDestination = DestinationCurrency.allDestinations[sender.selectedSegmentIndex]
        print("📍 Selected destination: \(selectedDestination.code) (\(selectedDestination.name))")
        print("📍 Currency symbol: \(selectedDestination.symbol)")
        
        // Update current destination
        currentDestinationCurrency = selectedDestination.code
        
        // Save selection
        UserDefaults.standard.set(selectedDestination.code, forKey: "selectedDestinationCurrency")
        print("💾 Saved destination to UserDefaults: \(selectedDestination.code)")
        
        // Clear existing rates
        print("🗑️  Clearing existing rates (\(self.rates.count) items)")
        self.rates = []
        self.rateCollection.reloadData()
        
        // Fetch new rates for selected destination
        print("📡 Calling getRates()...")
        let sourceCurrency = CurrencyManager.shared.selectedCurrency.code
        print("📡 Fetching rates: \(sourceCurrency) → \(selectedDestination.code)")
        
        self.getRates { (result) in
            switch result {
            case .Success(let data):
                print("✅ Successfully loaded \(data.count) providers for \(sourceCurrency) → \(selectedDestination.code)")
                print("✅ First 3 rates: \(data.prefix(3).map { "\($0.currency): \($0.rate)" }.joined(separator: ", "))")
                // Save to Core Data
                CoreDataStack.saveInCoreDataWith(array: data)
                print("🌍 ========== DESTINATION CHANGE COMPLETED ==========\n")
            case .Error(let errorMessage):
                print("❌ Error loading rates for \(selectedDestination.code): \(errorMessage)")
                print("🌍 ========== DESTINATION CHANGE FAILED ==========\n")
                DispatchQueue.main.async {
                    // Show error alert
                    let alert = UIAlertController(
                        title: "Error Loading Rates",
                        message: "Could not load rates for \(selectedDestination.name). Please check your internet connection.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    // MARK: - Currency Picker Actions
    
    @objc func showSourceCurrencyPicker() {
        let alert = UIAlertController(title: "Select Source Currency", message: nil, preferredStyle: .actionSheet)
        
        for (index, currency) in Currency.allCurrencies.enumerated() {
            let action = UIAlertAction(title: "\(currency.flag) \(currency.name) (\(currency.code))", style: .default) { _ in
                self.currencySegmentControl.selectedSegmentIndex = index
                self.fromCurrencyButton.setTitle("\(currency.flag) \(currency.code) ▼", for: .normal)
                self.currencyChanged(self.currencySegmentControl)
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = fromCurrencyButton
            popover.sourceRect = fromCurrencyButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc func showDestinationCurrencyPicker() {
        let alert = UIAlertController(title: "Select Destination Currency", message: nil, preferredStyle: .actionSheet)
        
        for (index, destination) in DestinationCurrency.allDestinations.enumerated() {
            let action = UIAlertAction(title: "\(destination.flag) \(destination.name) (\(destination.code))", style: .default) { _ in
                self.destinationSegmentControl.selectedSegmentIndex = index
                self.toCurrencyButton.setTitle("\(destination.flag) \(destination.code) ▼", for: .normal)
                self.destinationChanged(self.destinationSegmentControl)
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = toCurrencyButton
            popover.sourceRect = toCurrencyButton.bounds
        }
        
        present(alert, animated: true)
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
        
        // Add new side-by-side currency selector
        view.addSubview(currencyContainerView)
        currencyContainerView.addSubview(fromLabel)
        currencyContainerView.addSubview(fromCurrencyButton)
        currencyContainerView.addSubview(arrowLabel)
        currencyContainerView.addSubview(toLabel)
        currencyContainerView.addSubview(toCurrencyButton)
        
        view.addSubview(firstContainerView)
        view.addSubview(rateCollection)
        view.addSubview(disclaimerLabel)
        rateCollection.addSubview(noDataLabel)
        firstContainerView.addSubview(priceLabel)
        firstContainerView.addSubview(rateAlertButton)
        firstContainerView.addSubview(settingsButton)
        firstContainerView.addSubview(historyButton)
        firstContainerView.addSubview(mainTextField)
        firstContainerView.addSubview(tapToEditLabel)
        
        // Currency Container Constraints
        currencyContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        currencyContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        currencyContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        currencyContainerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // From Label
        fromLabel.topAnchor.constraint(equalTo: currencyContainerView.topAnchor, constant: 10).isActive = true
        fromLabel.leftAnchor.constraint(equalTo: currencyContainerView.leftAnchor, constant: 16).isActive = true
        
        // From Currency Button
        fromCurrencyButton.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: 6).isActive = true
        fromCurrencyButton.leftAnchor.constraint(equalTo: currencyContainerView.leftAnchor, constant: 16).isActive = true
        fromCurrencyButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        fromCurrencyButton.widthAnchor.constraint(equalToConstant: 130).isActive = true
        
        // Arrow Label
        arrowLabel.centerYAnchor.constraint(equalTo: fromCurrencyButton.centerYAnchor).isActive = true
        arrowLabel.centerXAnchor.constraint(equalTo: currencyContainerView.centerXAnchor).isActive = true
        
        // To Label
        toLabel.topAnchor.constraint(equalTo: currencyContainerView.topAnchor, constant: 10).isActive = true
        toLabel.rightAnchor.constraint(equalTo: currencyContainerView.rightAnchor, constant: -16).isActive = true
        
        // To Currency Button
        toCurrencyButton.topAnchor.constraint(equalTo: toLabel.bottomAnchor, constant: 6).isActive = true
        toCurrencyButton.rightAnchor.constraint(equalTo: currencyContainerView.rightAnchor, constant: -16).isActive = true
        toCurrencyButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        toCurrencyButton.widthAnchor.constraint(equalToConstant: 130).isActive = true
        
        priceLabel.leftAnchor.constraint(equalTo: firstContainerView.leftAnchor, constant: 8).isActive = true
        priceLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        priceLabel.topAnchor.constraint(equalTo: firstContainerView.topAnchor, constant: 8).isActive = true
        
        rateAlertButton.rightAnchor.constraint(equalTo: settingsButton.leftAnchor, constant: -8).isActive = true
        rateAlertButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        rateAlertButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        rateAlertButton.topAnchor.constraint(equalTo: firstContainerView.topAnchor, constant: 8).isActive = true
        
        settingsButton.rightAnchor.constraint(equalTo: historyButton.leftAnchor, constant: -8).isActive = true
        settingsButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        settingsButton.topAnchor.constraint(equalTo: firstContainerView.topAnchor, constant: 8).isActive = true
        
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
        
        firstContainerView.topAnchor.constraint(equalTo: currencyContainerView.bottomAnchor, constant: 16).isActive = true
        firstContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        firstContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        firstContainerView.heightAnchor.constraint(equalToConstant: 210).isActive = true
        
        
        mainTextField.topAnchor.constraint(equalTo: firstContainerView.topAnchor,constant: 50).isActive = true
        mainTextField.leftAnchor.constraint(equalTo: firstContainerView.leftAnchor,constant: 10).isActive = true
        mainTextField.rightAnchor.constraint(equalTo: firstContainerView.rightAnchor,constant: -10).isActive = true
        mainTextField.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        tapToEditLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        tapToEditLabel.centerXAnchor.constraint(equalTo: mainTextField.centerXAnchor).isActive = true
        tapToEditLabel.bottomAnchor.constraint(equalTo: mainTextField.bottomAnchor, constant: 30).isActive = true
        
        rateCollection.topAnchor.constraint(equalTo: firstContainerView.bottomAnchor,constant: 12).isActive = true
        rateCollection.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rateCollection.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        rateCollection.bottomAnchor.constraint(equalTo: disclaimerLabel.topAnchor, constant: -8).isActive = true
        rateCollection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        disclaimerLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        disclaimerLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        disclaimerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        disclaimerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 55).isActive = true
        
        rateAlertButton.addTarget(self, action: #selector(showRateAlertDialog), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(showHistory), for: .touchUpInside)
        
    }
    
    @objc fileprivate func showHistory() {
        let historyVC = HistoryViewController()
        let selectedCurrency = CurrencyManager.shared.selectedCurrency
        historyVC.sourceCurrency = selectedCurrency.code
        historyVC.remittanceObjects = CoreDataStack.getCoreDataObjects(forCurrency: selectedCurrency.code)
        //  let navigationVC = UINavigationController(rootViewController: historyVC)
        //  navigationVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        // navigationVC.navigationBar.backItem?.title = "Back"
        //  present(navigationVC, animated: true, completion: nil)
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    @objc fileprivate func showSettings() {
        let settingsVC = SettingsVC()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc fileprivate func showRateAlertDialog() {
        // Check notification permission first
        NotificationManager.shared.checkPermission { [weak self] granted in
            guard let self = self else { return }
            
            if !granted {
                // Request permission
                self.requestNotificationPermission()
                return
            }
            
            // Show rate alert dialog
            self.presentRateAlertDialog()
        }
    }
    
    private func requestNotificationPermission() {
        let alert = UIAlertController(
            title: "Enable Notifications",
            message: "To receive rate alerts, please enable notifications for this app.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Enable", style: .default) { [weak self] _ in
            NotificationManager.shared.requestPermission { granted in
                if granted {
                    self?.presentRateAlertDialog()
                } else {
                    self?.showSettingsPrompt()
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showSettingsPrompt() {
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please enable notifications in Settings to use rate alerts.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func presentRateAlertDialog() {
        let currency = CurrencyManager.shared.selectedCurrency
        let symbol = DestinationCurrency.symbol(for: currentDestinationCurrency)
        
        // Check if alert already exists
        let existingAlert = RateAlertManager.shared.getAlert(for: currency.code, targetCurrency: currentDestinationCurrency)
        
        let alert = UIAlertController(
            title: "🔔 Set Rate Alert",
            message: "Get notified when \(currency.code)→\(currentDestinationCurrency) reaches your target rate.\n\nCurrent rate: \(symbol)\(String(format: "%.2f", forexRate.rate))",
            preferredStyle: .alert
        )
        
        // Add text field for target rate
        alert.addTextField { textField in
            textField.placeholder = "Target rate (e.g., 90.00)"
            textField.keyboardType = UIKeyboardType.decimalPad
            if let existing = existingAlert {
                textField.text = String(format: "%.2f", existing.targetRate)
            }
        }
        
        // Above/Below picker
        alert.addAction(UIAlertAction(title: "Notify when ABOVE", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  let targetRate = Double(text) else {
                return
            }
            
            NotificationManager.shared.scheduleRateAlert(
                targetRate: targetRate,
                currency: currency.code,
                targetCurrency: self.currentDestinationCurrency,
                isAbove: true
            )
            
            self.showRateAlertConfirmation(targetRate: targetRate, isAbove: true)
        })
        
        alert.addAction(UIAlertAction(title: "Notify when BELOW", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  let targetRate = Double(text) else {
                return
            }
            
            NotificationManager.shared.scheduleRateAlert(
                targetRate: targetRate,
                currency: currency.code,
                targetCurrency: self.currentDestinationCurrency,
                isAbove: false
            )
            
            self.showRateAlertConfirmation(targetRate: targetRate, isAbove: false)
        })
        
        if existingAlert != nil {
            alert.addAction(UIAlertAction(title: "Remove Alert", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                RateAlertManager.shared.removeAlert(for: currency.code, targetCurrency: self.currentDestinationCurrency)
                self.showSimpleAlert(title: "Alert Removed", message: "Rate alert has been removed.")
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showRateAlertConfirmation(targetRate: Double, isAbove: Bool) {
        let currency = CurrencyManager.shared.selectedCurrency
        let symbol = DestinationCurrency.symbol(for: currentDestinationCurrency)
        let comparison = isAbove ? "above" : "below"
        
        showSimpleAlert(
            title: "✅ Alert Set!",
            message: "You'll be notified when \(currency.code)→\(currentDestinationCurrency) goes \(comparison) \(symbol)\(String(format: "%.2f", targetRate))"
        )
        
        // Update bell icon to show active alert
        updateRateAlertButtonAppearance()
    }
    
    private func updateRateAlertButtonAppearance() {
        let currency = CurrencyManager.shared.selectedCurrency
        let hasAlert = RateAlertManager.shared.hasAlert(for: currency.code, targetCurrency: currentDestinationCurrency)
        
        // Change icon based on alert status
        if hasAlert {
            rateAlertButton.setTitle("🔔", for: .normal) // Bell with notification
            rateAlertButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        } else {
            rateAlertButton.setTitle("🔔", for: .normal) // Regular bell
            rateAlertButton.backgroundColor = UIColor.clear
        }
    }
    
    private func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
        
        // Set initial source currency selection
        let savedCurrency = CurrencyManager.shared.selectedCurrency
        if let index = Currency.allCurrencies.firstIndex(where: { $0.code == savedCurrency.code }) {
            currencySegmentControl.selectedSegmentIndex = index
        }
        updateCurrencySymbol()
        
        // Load saved destination currency
        if let savedDestination = UserDefaults.standard.string(forKey: "selectedDestinationCurrency"),
           let index = DestinationCurrency.allDestinations.firstIndex(where: { $0.code == savedDestination }) {
            destinationSegmentControl.selectedSegmentIndex = index
            currentDestinationCurrency = savedDestination
            print("💾 Loaded saved destination: \(savedDestination)")
        } else {
            // Default to INR
            currentDestinationCurrency = "INR"
            print("💾 Using default destination: INR")
        }
        
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
                    self.rates = currentDayObjects.compactMap({ Rate(currency: $0.currancy ?? "unknown", rate: $0.rate, dateString: $0.dateString ?? "", forexRate: $0.forexRate ?? "", sourceCurrency: $0.sourceCurrency ?? "USD")})
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
