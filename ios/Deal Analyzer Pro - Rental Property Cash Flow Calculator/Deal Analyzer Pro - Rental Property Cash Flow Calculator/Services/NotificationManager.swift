//
//  NotificationManager.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import SwiftUI
import UserNotifications

/// Manages local notifications for due diligence reminders
@Observable
class NotificationManager {
    static let shared = NotificationManager()
    
    var isAuthorized: Bool = false
    var pendingNotifications: [UNNotificationRequest] = []
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Schedule Notifications
    
    func scheduleDueDiligenceReminder(
        dealName: String,
        task: String,
        dueDate: Date,
        identifier: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Due Diligence Reminder"
        content.subtitle = dealName
        content.body = task
        content.sound = .default
        content.badge = 1
        
        // Schedule for 9 AM on the due date
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: dueDate)
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleRentDueReminder(
        dealName: String,
        dayOfMonth: Int = 1
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Rent Due"
        content.subtitle = dealName
        content.body = "It's time to collect rent for \(dealName)"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.day = dayOfMonth
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "rent-\(dealName)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleInspectionReminder(
        dealName: String,
        inspectionDate: Date
    ) {
        // Day before reminder
        let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: inspectionDate)!
        
        let content = UNMutableNotificationContent()
        content.title = "Inspection Tomorrow"
        content.subtitle = dealName
        content.body = "Don't forget your property inspection tomorrow"
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: dayBefore)
        dateComponents.hour = 18 // 6 PM reminder
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "inspection-\(dealName)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Cancel Notifications
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Fetch Pending Notifications
    
    func fetchPendingNotifications() async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        await MainActor.run {
            self.pendingNotifications = requests
        }
    }
}

// MARK: - Reminder Types

enum ReminderType: String, CaseIterable, Codable {
    case dueDiligence = "Due Diligence"
    case rentCollection = "Rent Collection"
    case inspection = "Inspection"
    case mortgagePayment = "Mortgage Payment"
    case insuranceRenewal = "Insurance Renewal"
    case propertyTax = "Property Tax"
    case leaseRenewal = "Lease Renewal"
    case maintenance = "Maintenance"
    
    var icon: String {
        switch self {
        case .dueDiligence: return "checklist"
        case .rentCollection: return "dollarsign.circle.fill"
        case .inspection: return "magnifyingglass"
        case .mortgagePayment: return "house.fill"
        case .insuranceRenewal: return "shield.fill"
        case .propertyTax: return "building.columns.fill"
        case .leaseRenewal: return "doc.text.fill"
        case .maintenance: return "wrench.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .dueDiligence: return .blue
        case .rentCollection: return .green
        case .inspection: return .orange
        case .mortgagePayment: return .purple
        case .insuranceRenewal: return .red
        case .propertyTax: return .pink
        case .leaseRenewal: return .cyan
        case .maintenance: return .yellow
        }
    }
}
