import Foundation
import SwiftData

/// Persisted user preferences using SwiftData
@Model
final class UserPreferences {
    var cycleLength: Int
    var periodLength: Int
    var lastPeriodStart: Date
    var hasCompletedOnboarding: Bool
    var notifyPeriodReminder: Bool
    var notifyLogReminder: Bool
    var notifyOvulation: Bool
    var periodReminderDays: Int  // days before period to notify
    
    init(
        cycleLength: Int = 28,
        periodLength: Int = 5,
        lastPeriodStart: Date = Date(),
        hasCompletedOnboarding: Bool = false,
        notifyPeriodReminder: Bool = true,
        notifyLogReminder: Bool = true,
        notifyOvulation: Bool = false,
        periodReminderDays: Int = 3
    ) {
        self.cycleLength = cycleLength
        self.periodLength = periodLength
        self.lastPeriodStart = lastPeriodStart
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.notifyPeriodReminder = notifyPeriodReminder
        self.notifyLogReminder = notifyLogReminder
        self.notifyOvulation = notifyOvulation
        self.periodReminderDays = periodReminderDays
    }
}
