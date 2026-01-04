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
        table.separatorStyle = .none
        if #available(iOS 13.0, *) {
            table.backgroundColor = .systemGroupedBackground
        } else {
            table.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        }
        return table
    }()
    
    private let navigationBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
            let image = UIImage(systemName: "chevron.left", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = .label
        } else {
            button.setTitle("←", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
            button.setTitleColor(.black, for: .normal)
        }
        
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Settings"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }()
    
    // MARK: - Data
    
    private enum SettingsSection: Int, CaseIterable {
        case notifications
        case reminders
        case contact
        case app
        case legal
        
        var title: String {
            switch self {
            case .notifications: return "Notifications"
            case .reminders: return "Reminders"
            case .contact: return "Contact & Support"
            case .app: return "About"
            case .legal: return "Legal"
            }
        }
    }
    
    private enum SettingsRow {
        case dailySummary
        case manageAlerts
        case transferReminders
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
            case .transferReminders: return "Transfer Reminders"
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
            case .transferReminders: return "calendar.badge.clock"
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
            case .dailySummary: return UIColor(red: 87/255, green: 202/255, blue: 133/255, alpha: 1.0)
            case .manageAlerts: return UIColor(red: 240/255, green: 47/255, blue: 194/255, alpha: 1.0)
            case .transferReminders: return UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0)
            case .email: return UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 1.0)
            case .twitter: return UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1.0)
            case .website: return UIColor(red: 251/255, green: 146/255, blue: 60/255, alpha: 1.0)
            case .version: return UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
            case .rateApp: return UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1.0)
            case .privacyPolicy: return UIColor(red: 168/255, green: 85/255, blue: 247/255, alpha: 1.0)
            case .termsOfService: return UIColor(red: 52/255, green: 58/255, blue: 64/255, alpha: 1.0)
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
            case .transferReminders:
                let enabled = UserDefaults.standard.bool(forKey: "transferRemindersEnabled")
                return enabled ? "Enabled" : "Set recurring reminders"
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
        [.transferReminders],
        [.email, .website, .twitter],
        [.version, .rateApp],
        [.privacyPolicy, .termsOfService]
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show navigation bar when leaving
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGroupedBackground
        } else {
            view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        }
        
        // Add navigation bar
        view.addSubview(navigationBar)
        navigationBar.addSubview(backButton)
        navigationBar.addSubview(titleLabel)
        
        // Add table view
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        
        // Navigation Bar Constraints
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            
            backButton.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 4),
            backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 4),
            titleLabel.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: navigationBar.trailingAnchor, constant: -20),
        ])
        
        // Table Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func backButtonTapped() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        navigationController?.popViewController(animated: true)
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as? SettingsCell else {
            return UITableViewCell()
        }
        
        let row = sections[indexPath.section][indexPath.row]
        let isLastInSection = indexPath.row == sections[indexPath.section].count - 1
        
        // Configure cell
        cell.configure(
            icon: row.iconName,
            iconColor: row.iconColor,
            title: row.title,
            subtitle: row.subtitle,
            isLastInSection: isLastInSection
        )
        
        // Version row is not actionable
        if case .version = row {
            cell.isUserInteractionEnabled = false
            cell.alpha = 0.6
        } else {
            cell.isUserInteractionEnabled = true
            cell.alpha = 1.0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = SettingsSection(rawValue: section)?.title.uppercased()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .gray
        }
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let row = sections[indexPath.section][indexPath.row]
        
        switch row {
        case .dailySummary:
            handleDailySummary()
        case .manageAlerts:
            handleManageAlerts()
        case .transferReminders:
            handleTransferReminders()
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
    
    // MARK: - New Feature Handlers
    
    private func handleTransferReminders() {
        let alert = UIAlertController(
            title: "📅 Transfer Reminders",
            message: "Set up recurring reminders for your regular transfers. Choose your reminder schedule:",
            preferredStyle: .actionSheet
        )
        
        let schedules = [
            ("Weekly", "Every week"),
            ("Bi-weekly", "Every 2 weeks"),
            ("Monthly", "Every month"),
            ("Custom", "Set custom schedule")
        ]
        
        for (title, subtitle) in schedules {
            alert.addAction(UIAlertAction(title: "\(title) - \(subtitle)", style: .default) { [weak self] _ in
                UserDefaults.standard.set(true, forKey: "transferRemindersEnabled")
                UserDefaults.standard.set(title, forKey: "transferReminderSchedule")
                self?.tableView.reloadData()
                self?.showSimpleAlert(
                    title: "✅ Reminder Set!",
                    message: "You'll receive \(title.lowercased()) reminders for your transfers."
                )
            })
        }
        
        alert.addAction(UIAlertAction(title: "Disable Reminders", style: .destructive) { [weak self] _ in
            UserDefaults.standard.set(false, forKey: "transferRemindersEnabled")
            self?.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
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
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            view.backgroundColor = .separator
        } else {
            view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        }
        return view
    }()
    
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
    
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
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
            label.textColor = .lightGray
        }
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            imageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
            imageView.tintColor = .tertiaryLabel
        }
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        containerView.addSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)
        containerView.addSubview(chevronImageView)
        contentView.addSubview(separatorLine)
        
        NSLayoutConstraint.activate([
            // Container view - full width
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Icon container
            iconContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 32),
            iconContainerView.heightAnchor.constraint(equalToConstant: 32),
            
            // Icon
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            // Text stack
            textStackView.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 12),
            textStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textStackView.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -12),
            
            // Chevron
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12),
            
            // Separator line
            separatorLine.leadingAnchor.constraint(equalTo: textStackView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
    
    func configure(icon: String, iconColor: UIColor, title: String, subtitle: String?, isLastInSection: Bool) {
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: icon)
        } else {
            iconImageView.image = nil
        }
        iconContainerView.backgroundColor = iconColor
        titleLabel.text = title
        
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
        
        // Hide separator for last cell in section
        separatorLine.isHidden = isLastInSection
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.15) {
            self.containerView.backgroundColor = highlighted ? UIColor(white: 0.95, alpha: 1.0) : .white
        }
    }
}
