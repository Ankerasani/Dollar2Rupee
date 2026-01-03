//
//  SettingsVC.swift
//  Dollar2Rupee
//
//  Created by AI Assistant on 1/3/26.
//  Copyright © 2026 Ankersani. All rights reserved.
//

import UIKit
import MessageUI

class SettingsVC: UIViewController {
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            table.backgroundColor = .systemGroupedBackground
        } else {
            table.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        }
        return table
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)
        return view
    }()
    
    private let appIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.backgroundColor = .white
        
        // Use app icon or placeholder
        if let icon = UIImage(named: "AppIcon") {
            imageView.image = icon
        } else {
            // Placeholder
            imageView.image = UIImage(systemName: "app.fill")
            imageView.tintColor = #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)
        }
        
        return imageView
    }()
    
    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Dollar2Rupee"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let appTaglineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Compare. Save. Transfer."
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Data
    
    private enum SettingsSection: Int, CaseIterable {
        case notifications
        case contact
        case app
        case legal
        
        var title: String {
            switch self {
            case .notifications: return "Notifications"
            case .contact: return "Contact & Support"
            case .app: return "About"
            case .legal: return "Legal"
            }
        }
    }
    
    private enum SettingsRow {
        case dailySummary
        case manageAlerts
        case email
        case twitter
        case website
        case version
        case rateApp
        case privacyPolicy
        case termsOfService
        
        var title: String {
            switch self {
            case .dailySummary: return "Daily Rate Summary"
            case .manageAlerts: return "Manage Rate Alerts"
            case .email: return "Email Support"
            case .twitter: return "Follow on Twitter"
            case .website: return "Visit Website"
            case .version: return "App Version"
            case .rateApp: return "Rate on App Store"
            case .privacyPolicy: return "Privacy Policy"
            case .termsOfService: return "Terms of Service"
            }
        }
        
        var iconName: String {
            switch self {
            case .dailySummary: return "chart.bar.fill"
            case .manageAlerts: return "bell.fill"
            case .email: return "envelope.fill"
            case .twitter: return "person.2.fill"
            case .website: return "globe"
            case .version: return "info.circle.fill"
            case .rateApp: return "star.fill"
            case .privacyPolicy: return "lock.shield.fill"
            case .termsOfService: return "doc.text.fill"
            }
        }
        
        var iconColor: UIColor {
            switch self {
            case .dailySummary: return #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)
            case .manageAlerts: return #colorLiteral(red: 0.9411764706, green: 0.1843137255, blue: 0.7607843137, alpha: 1)
            case .email: return #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            case .twitter: return #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            case .website: return #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            case .version: return #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            case .rateApp: return #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            case .privacyPolicy: return #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
            case .termsOfService: return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            }
        }
        
        var subtitle: String? {
            switch self {
            case .dailySummary:
                let enabled = UserDefaults.standard.bool(forKey: "dailySummaryEnabled")
                return enabled ? "Enabled" : "Tap to enable"
            case .manageAlerts:
                let count = RateAlertManager.shared.getAllAlerts().count
                return count > 0 ? "\(count) active alert\(count > 1 ? "s" : "")" : "No active alerts"
            case .email: return "support@compareremit.com"
            case .twitter: return "@compareremit"
            case .website: return "compareremit.com"
            case .version: return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
            default: return nil
            }
        }
    }
    
    private let sections: [[SettingsRow]] = [
        [.dailySummary, .manageAlerts],
        [.email, .website, .twitter],
        [.version, .rateApp],
        [.privacyPolicy, .termsOfService]
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Settings"
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGroupedBackground
        } else {
            view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        }
        
        // Add header view
        view.addSubview(headerView)
        headerView.addSubview(appIconImageView)
        headerView.addSubview(appNameLabel)
        headerView.addSubview(appTaglineLabel)
        
        // Add table view
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        
        // Header Constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 200),
            
            appIconImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            appIconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            appIconImageView.widthAnchor.constraint(equalToConstant: 80),
            appIconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            appNameLabel.topAnchor.constraint(equalTo: appIconImageView.bottomAnchor, constant: 12),
            appNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            appNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            appTaglineLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 4),
            appTaglineLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            appTaglineLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
        ])
        
        // Table Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Back button styling
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3411764706, green: 0.7921568627, blue: 0.5215686275, alpha: 1)
        }
    }
    
    // MARK: - Actions
    
    private func handleEmailSupport() {
        let email = "support@compareremit.com"
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setSubject("CompareRemit Support Request")
            
            // Add app version and device info
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
            let device = UIDevice.current.model
            let osVersion = UIDevice.current.systemVersion
            
            let body = "\n\n\n---\nApp Version: \(version) (\(build))\nDevice: \(device)\niOS: \(osVersion)"
            mail.setMessageBody(body, isHTML: false)
            
            present(mail, animated: true)
        } else {
            // Fallback to mailto: URL
            if let url = URL(string: "mailto:\(email)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    showAlert(title: "Email Not Available", message: "Please email us at \(email)")
                }
            }
        }
    }
    
    private func handleWebsite() {
        if let url = URL(string: "https://compareremit.com") {
            UIApplication.shared.open(url)
        }
    }
    
    private func handleTwitter() {
        if let url = URL(string: "https://twitter.com/compareremit") {
            UIApplication.shared.open(url)
        }
    }
    
    private func handleRateApp() {
        // Replace with your actual App Store ID
        let appID = "YOUR_APP_STORE_ID"
        if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    private func handlePrivacyPolicy() {
        if let url = URL(string: "https://compareremit.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    private func handleTermsOfService() {
        if let url = URL(string: "https://compareremit.com/terms") {
            UIApplication.shared.open(url)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingsSection(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as? SettingsCell else {
            return UITableViewCell()
        }
        
        let row = sections[indexPath.section][indexPath.row]
        
        // Configure cell
        cell.configure(
            icon: row.iconName,
            iconColor: row.iconColor,
            title: row.title,
            subtitle: row.subtitle
        )
        
        // Show disclosure indicator for actionable items
        switch row {
        case .version:
            cell.accessoryType = .none
            cell.selectionStyle = .none
        default:
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = sections[indexPath.section][indexPath.row]
        
        switch row {
        case .dailySummary:
            handleDailySummary()
        case .manageAlerts:
            handleManageAlerts()
        case .email:
            handleEmailSupport()
        case .website:
            handleWebsite()
        case .twitter:
            handleTwitter()
        case .rateApp:
            handleRateApp()
        case .privacyPolicy:
            handlePrivacyPolicy()
        case .termsOfService:
            handleTermsOfService()
        case .version:
            break // Not actionable
        }
    }
}

// MARK: - Notification Handlers

extension SettingsVC {
    
    private func handleDailySummary() {
        let isEnabled = UserDefaults.standard.bool(forKey: "dailySummaryEnabled")
        
        if isEnabled {
            // Show disable confirmation
            let alert = UIAlertController(
                title: "Disable Daily Summary?",
                message: "You won't receive daily rate notifications anymore.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Disable", style: .destructive) { [weak self] _ in
                NotificationManager.shared.cancelDailySummary()
                self?.tableView.reloadData()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        } else {
            // Show enable dialog with time picker
            showDailySummaryTimePicker()
        }
    }
    
    private func showDailySummaryTimePicker() {
        let alert = UIAlertController(
            title: "📊 Daily Rate Summary",
            message: "Get a daily notification with today's best rates. Choose your preferred time:",
            preferredStyle: .actionSheet
        )
        
        let times = [
            (9, "9:00 AM (Morning)"),
            (12, "12:00 PM (Noon)"),
            (18, "6:00 PM (Evening)"),
            (20, "8:00 PM (Night)")
        ]
        
        for (hour, label) in times {
            alert.addAction(UIAlertAction(title: label, style: .default) { [weak self] _ in
                // Check permission first
                NotificationManager.shared.checkPermission { granted in
                    if granted {
                        NotificationManager.shared.scheduleDailySummary(at: hour)
                        self?.tableView.reloadData()
                        self?.showSimpleAlert(
                            title: "✅ Daily Summary Enabled!",
                            message: "You'll receive daily rate updates at \(label.components(separatedBy: " (").first ?? "")"
                        )
                    } else {
                        // Request permission
                        NotificationManager.shared.requestPermission { permissionGranted in
                            if permissionGranted {
                                NotificationManager.shared.scheduleDailySummary(at: hour)
                                self?.tableView.reloadData()
                                self?.showSimpleAlert(
                                    title: "✅ Daily Summary Enabled!",
                                    message: "You'll receive daily rate updates at \(label.components(separatedBy: " (").first ?? "")"
                                )
                            } else {
                                self?.showSettingsPrompt()
                            }
                        }
                    }
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func handleManageAlerts() {
        let alerts = RateAlertManager.shared.getAllAlerts()
        
        if alerts.isEmpty {
            showSimpleAlert(
                title: "No Active Alerts",
                message: "Tap the 🔔 bell icon on the main screen to set up a rate alert."
            )
            return
        }
        
        // Show list of active alerts
        let alert = UIAlertController(
            title: "🔔 Active Rate Alerts",
            message: "Manage your active rate alerts:",
            preferredStyle: .actionSheet
        )
        
        for rateAlert in alerts {
            let symbol = DestinationCurrency.symbol(for: rateAlert.targetCurrency)
            let comparison = rateAlert.isAbove ? "above" : "below"
            let title = "\(rateAlert.currency)→\(rateAlert.targetCurrency): \(comparison) \(symbol)\(String(format: "%.2f", rateAlert.targetRate))"
            
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.showRemoveAlertConfirmation(for: rateAlert)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Remove All", style: .destructive) { [weak self] _ in
            self?.showRemoveAllAlertsConfirmation()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showRemoveAlertConfirmation(for alert: RateAlertManager.RateAlert) {
        let symbol = DestinationCurrency.symbol(for: alert.targetCurrency)
        let comparison = alert.isAbove ? "above" : "below"
        
        let confirmAlert = UIAlertController(
            title: "Remove Alert?",
            message: "Remove alert for \(alert.currency)→\(alert.targetCurrency) \(comparison) \(symbol)\(String(format: "%.2f", alert.targetRate))?",
            preferredStyle: .alert
        )
        
        confirmAlert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            RateAlertManager.shared.removeAlert(for: alert.currency, targetCurrency: alert.targetCurrency)
            self?.tableView.reloadData()
            self?.showSimpleAlert(title: "Alert Removed", message: "The rate alert has been removed.")
        })
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(confirmAlert, animated: true)
    }
    
    private func showRemoveAllAlertsConfirmation() {
        let alert = UIAlertController(
            title: "Remove All Alerts?",
            message: "This will remove all your active rate alerts.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Remove All", style: .destructive) { [weak self] _ in
            RateAlertManager.shared.removeAllAlerts()
            self?.tableView.reloadData()
            self?.showSimpleAlert(title: "All Alerts Removed", message: "All rate alerts have been removed.")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showSettingsPrompt() {
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please enable notifications in Settings to receive rate alerts.",
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
    
    private func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension SettingsVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - Custom Settings Cell

class SettingsCell: UITableViewCell {
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .gray
        }
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            // Icon container
            iconContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 36),
            iconContainerView.heightAnchor.constraint(equalToConstant: 36),
            
            // Icon
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            // Subtitle
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
    }
    
    func configure(icon: String, iconColor: UIColor, title: String, subtitle: String?) {
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: icon)
        } else {
            iconImageView.image = nil
        }
        iconContainerView.backgroundColor = iconColor
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
    }
}

