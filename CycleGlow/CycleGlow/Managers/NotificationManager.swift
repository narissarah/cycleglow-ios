import Foundation
import UserNotifications

/// Manages local notification scheduling for cycle events
@Observable
class NotificationManager {
    
    static let shared = NotificationManager()
    
    private(set) var isAuthorized = false
    
    private let center = UNUserNotificationCenter.current()
    
    // Notification category identifiers
    private enum Category {
        static let periodReminder = "PERIOD_REMINDER"
        static let dailyLog = "DAILY_LOG_REMINDER"
        static let ovulation = "OVULATION_ALERT"
    }
    
    private init() {
        Task { await checkAuthorizationStatus() }
    }
    
    // MARK: - Authorization
    
    /// Check current authorization status without prompting
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    /// Request notification permission. Returns true if granted.
    @discardableResult
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            print("CycleGlow: Notification permission error: \(error)")
            isAuthorized = false
            return false
        }
    }
    
    // MARK: - Schedule All Notifications
    
    /// Reschedule all notifications based on current preferences and cycle data
    func rescheduleAll(
        lastPeriodStart: Date,
        cycleLength: Int,
        periodLength: Int,
        notifyPeriodReminder: Bool,
        periodReminderDays: Int,
        notifyLogReminder: Bool,
        notifyOvulation: Bool
    ) async {
        // Remove all pending notifications first
        center.removeAllPendingNotificationRequests()
        
        guard isAuthorized else { return }
        
        if notifyPeriodReminder {
            await schedulePeriodReminders(
                lastPeriodStart: lastPeriodStart,
                cycleLength: cycleLength,
                reminderDaysBefore: periodReminderDays
            )
        }
        
        if notifyLogReminder {
            await scheduleDailyLogReminder()
        }
        
        if notifyOvulation {
            await scheduleOvulationAlert(
                lastPeriodStart: lastPeriodStart,
                cycleLength: cycleLength
            )
        }
    }
    
    // MARK: - Period Reminder
    
    /// Schedule period reminders for the next 3 predicted cycles
    private func schedulePeriodReminders(
        lastPeriodStart: Date,
        cycleLength: Int,
        reminderDaysBefore: Int
    ) async {
        let calendar = Calendar.current
        
        for cycleIndex in 0..<6 {
            // Calculate next period start date
            let daysToAdd = cycleLength * (cycleIndex + 1)
            guard let nextPeriodDate = calendar.date(byAdding: .day, value: daysToAdd, to: lastPeriodStart) else { continue }
            
            // Reminder date = period date minus reminder days
            guard let reminderDate = calendar.date(byAdding: .day, value: -reminderDaysBefore, to: nextPeriodDate) else { continue }
            
            // Skip if reminder date is in the past
            guard reminderDate > Date() else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "Period Coming Soon 🌸"
            content.body = "Your period is expected in \(reminderDaysBefore) day\(reminderDaysBefore == 1 ? "" : "s"). Time to prepare!"
            content.sound = .default
            content.categoryIdentifier = Category.periodReminder
            
            // Schedule at 9 AM on the reminder date
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: reminderDate)
            dateComponents.hour = 9
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(Category.periodReminder)_\(cycleIndex)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await center.add(request)
            } catch {
                print("CycleGlow: Failed to schedule period reminder: \(error)")
            }
        }
    }
    
    // MARK: - Daily Log Reminder
    
    /// Schedule a repeating daily log reminder at 8 PM
    private func scheduleDailyLogReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Time to Log 📝"
        content.body = "How was your day? Log your mood, skin, and symptoms."
        content.sound = .default
        content.categoryIdentifier = Category.dailyLog
        
        // Daily at 8 PM
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: Category.dailyLog,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
        } catch {
            print("CycleGlow: Failed to schedule daily log reminder: \(error)")
        }
    }
    
    // MARK: - Ovulation Alert
    
    /// Schedule ovulation alerts for the next 3 predicted cycles
    private func scheduleOvulationAlert(
        lastPeriodStart: Date,
        cycleLength: Int
    ) async {
        let calendar = Calendar.current
        
        // Ovulation typically occurs ~14 days before next period
        let ovulationDayInCycle = max(1, cycleLength - 14)
        
        for cycleIndex in 0..<6 {
            let cycleStartOffset = cycleLength * cycleIndex
            let daysToOvulation = cycleStartOffset + ovulationDayInCycle
            
            guard let ovulationDate = calendar.date(byAdding: .day, value: daysToOvulation, to: lastPeriodStart) else { continue }
            
            // Skip if in the past
            guard ovulationDate > Date() else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "Ovulation Day ☀️"
            content.body = "Today is your predicted ovulation day. You may feel extra energetic and glowy!"
            content.sound = .default
            content.categoryIdentifier = Category.ovulation
            
            // Schedule at 9 AM on ovulation day
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: ovulationDate)
            dateComponents.hour = 9
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(Category.ovulation)_\(cycleIndex)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await center.add(request)
            } catch {
                print("CycleGlow: Failed to schedule ovulation alert: \(error)")
            }
        }
    }
    
    // MARK: - Cleanup
    
    /// Remove all scheduled notifications
    func removeAll() {
        center.removeAllPendingNotificationRequests()
    }
}
