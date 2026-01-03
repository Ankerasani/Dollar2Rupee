//
//  NotificationManager.swift
//  Dollar2Rupee
//
//  Created by AI Assistant on 1/3/26.
//  Copyright © 2026 Ankersani. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Permission Management
    
    /// Request notification permissions from user
    func requestPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    /// Check if notifications are authorized
    func checkPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // MARK: - Rate Alert Notifications
    
    /// Schedule a rate alert notification to check periodically
    /// - Parameters:
    ///   - targetRate: The target rate to alert on
    ///   - currency: Source currency (e.g., "USD")
    ///   - targetCurrency: Target currency (e.g., "INR")
    ///   - isAbove: true for "above", false for "below"
    func scheduleRateAlert(targetRate: Double, currency: String, targetCurrency: String, isAbove: Bool) {
        // Store alert settings
        RateAlertManager.shared.saveAlert(targetRate: targetRate, currency: currency, targetCurrency: targetCurrency, isAbove: isAbove)
        
        print("✅ Rate alert scheduled: \(currency)→\(targetCurrency) \(isAbove ? ">" : "<") \(targetRate)")
    }
    
    /// Check if rate alert condition is met and send notification
    func checkRateAlerts(currentRate: Double, currency: String, targetCurrency: String, providerName: String) {
        guard let alert = RateAlertManager.shared.getAlert(for: currency, targetCurrency: targetCurrency) else {
            return
        }
        
        let conditionMet = alert.isAbove ? (currentRate >= alert.targetRate) : (currentRate <= alert.targetRate)
        
        if conditionMet {
            sendRateAlertNotification(
                currentRate: currentRate,
                targetRate: alert.targetRate,
                currency: currency,
                targetCurrency: targetCurrency,
                providerName: providerName,
                isAbove: alert.isAbove
            )
            
            // Remove alert after triggering (one-time alert)
            RateAlertManager.shared.removeAlert(for: currency, targetCurrency: targetCurrency)
        }
    }
    
    private func sendRateAlertNotification(currentRate: Double, targetRate: Double, currency: String, targetCurrency: String, providerName: String, isAbove: Bool) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Rate Alert!"
        
        let symbol = DestinationCurrency.symbol(for: targetCurrency)
        let comparison = isAbove ? "above" : "below"
        content.body = "\(currency)→\(targetCurrency) is now \(symbol)\(String(format: "%.2f", currentRate)) (\(comparison) your target of \(symbol)\(String(format: "%.2f", targetRate)))! Best rate: \(providerName)"
        content.sound = .default()
        content.badge = 1
        
        let request = UNNotificationRequest(identifier: "rateAlert-\(currency)-\(targetCurrency)", content: content, trigger: nil)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Error sending rate alert notification: \(error.localizedDescription)")
            } else {
                print("✅ Rate alert notification sent!")
            }
        }
    }
    
    // MARK: - Daily Rate Summary Notifications
    
    /// Schedule daily rate summary notification
    /// - Parameter hour: Hour of day (0-23) to send notification
    func scheduleDailySummary(at hour: Int) {
        // Remove existing daily summary notifications
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["dailySummary"])
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create placeholder content (will be updated when notification fires)
        let content = UNMutableNotificationContent()
        content.title = "Daily Rate Summary"
        content.body = "Tap to see today's best rates"
        content.sound = .default()
        content.categoryIdentifier = "DAILY_SUMMARY"
        
        let request = UNNotificationRequest(identifier: "dailySummary", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Error scheduling daily summary: \(error.localizedDescription)")
            } else {
                print("✅ Daily summary scheduled for \(hour):00")
                UserDefaults.standard.set(hour, forKey: "dailySummaryHour")
                UserDefaults.standard.set(true, forKey: "dailySummaryEnabled")
            }
        }
    }
    
    /// Send daily rate summary with current data
    func sendDailySummary(bestRate: Double, providerName: String, currency: String, targetCurrency: String, trendDirection: String) {
        let content = UNMutableNotificationContent()
        
        let timeOfDay = getTimeOfDayGreeting()
        content.title = "\(timeOfDay)!"
        
        let symbol = DestinationCurrency.symbol(for: targetCurrency)
        content.body = "Today's best \(currency)→\(targetCurrency) rate: \(symbol)\(String(format: "%.2f", bestRate)) (\(providerName))\n\(trendDirection)"
        content.sound = .default()
        content.badge = 1
        
        let request = UNNotificationRequest(identifier: "dailySummaryNow", content: content, trigger: nil)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Error sending daily summary: \(error.localizedDescription)")
            } else {
                print("✅ Daily summary sent!")
            }
        }
    }
    
    /// Cancel daily summary notifications
    func cancelDailySummary() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["dailySummary"])
        UserDefaults.standard.set(false, forKey: "dailySummaryEnabled")
        print("✅ Daily summary cancelled")
    }
    
    // MARK: - Rate Drop Alert
    
    /// Send notification when rate drops significantly
    func sendRateDropAlert(currentRate: Double, previousRate: Double, currency: String, targetCurrency: String) {
        let drop = previousRate - currentRate
        
        guard drop > 0.3 else { return } // Only alert on significant drops
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Rate Drop Alert!"
        
        let symbol = DestinationCurrency.symbol(for: targetCurrency)
        content.body = "\(currency)→\(targetCurrency) dropped to \(symbol)\(String(format: "%.2f", currentRate)) (-\(String(format: "%.2f", drop)) today). Might be a good time to wait..."
        content.sound = .default()
        
        let request = UNNotificationRequest(identifier: "rateDrop-\(UUID().uuidString)", content: content, trigger: nil)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Error sending rate drop alert: \(error.localizedDescription)")
            } else {
                print("✅ Rate drop alert sent!")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func getTimeOfDayGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning! 🌅"
        case 12..<17: return "Good afternoon! ☀️"
        case 17..<22: return "Good evening! 🌆"
        default: return "Good night! 🌙"
        }
    }
    
    /// Clear all notification badges
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    /// Remove all pending notifications
    func removeAllPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}

// MARK: - Rate Alert Storage Manager

class RateAlertManager {
    
    static let shared = RateAlertManager()
    
    private let alertsKey = "rateAlerts"
    
    struct RateAlert: Codable {
        let targetRate: Double
        let currency: String
        let targetCurrency: String
        let isAbove: Bool
        let createdAt: Date
    }
    
    private init() {}
    
    /// Save a rate alert
    func saveAlert(targetRate: Double, currency: String, targetCurrency: String, isAbove: Bool) {
        var alerts = getAllAlerts()
        
        // Remove existing alert for same currency pair if exists
        alerts.removeAll { $0.currency == currency && $0.targetCurrency == targetCurrency }
        
        // Add new alert
        let newAlert = RateAlert(
            targetRate: targetRate,
            currency: currency,
            targetCurrency: targetCurrency,
            isAbove: isAbove,
            createdAt: Date()
        )
        alerts.append(newAlert)
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(alerts) {
            UserDefaults.standard.set(encoded, forKey: alertsKey)
            print("✅ Rate alert saved: \(currency)→\(targetCurrency) \(isAbove ? ">" : "<") \(targetRate)")
        }
    }
    
    /// Get alert for specific currency pair
    func getAlert(for currency: String, targetCurrency: String) -> RateAlert? {
        return getAllAlerts().first { $0.currency == currency && $0.targetCurrency == targetCurrency }
    }
    
    /// Get all active alerts
    func getAllAlerts() -> [RateAlert] {
        guard let data = UserDefaults.standard.data(forKey: alertsKey),
              let alerts = try? JSONDecoder().decode([RateAlert].self, from: data) else {
            return []
        }
        return alerts
    }
    
    /// Remove alert for specific currency pair
    func removeAlert(for currency: String, targetCurrency: String) {
        var alerts = getAllAlerts()
        alerts.removeAll { $0.currency == currency && $0.targetCurrency == targetCurrency }
        
        if let encoded = try? JSONEncoder().encode(alerts) {
            UserDefaults.standard.set(encoded, forKey: alertsKey)
            print("✅ Rate alert removed: \(currency)→\(targetCurrency)")
        }
    }
    
    /// Check if alert exists for currency pair
    func hasAlert(for currency: String, targetCurrency: String) -> Bool {
        return getAlert(for: currency, targetCurrency: targetCurrency) != nil
    }
    
    /// Remove all alerts
    func removeAllAlerts() {
        UserDefaults.standard.removeObject(forKey: alertsKey)
        print("✅ All rate alerts removed")
    }
}

