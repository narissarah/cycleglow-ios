import SwiftUI
import SwiftData

@Observable
class CycleViewModel {
    // MARK: - Persisted via SwiftData
    
    var lastPeriodStart: Date = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
    var cycleLength: Int = 28
    var periodLength: Int = 5
    var hasCompletedOnboarding: Bool = false
    
    // Notification preferences
    var notifyPeriodReminder: Bool = true
    var notifyLogReminder: Bool = true
    var notifyOvulation: Bool = false
    var periodReminderDays: Int = 3
    
    // MARK: - Daily log (UI state)
    
    var todayMood: Int = 3
    var todaySkin: SkinCondition = .clear
    var todayEnergy: Int = 3
    var todaySymptoms: Set<Symptom> = []
    var todayNotes: String = ""
    
    // MARK: - SwiftData context
    
    var modelContext: ModelContext?
    
    // MARK: - Computed (uses CycleManager)
    
    var currentDay: Int {
        CycleManager.currentDay(lastPeriodStart: lastPeriodStart, cycleLength: cycleLength)
    }
    
    var currentPhase: CyclePhase {
        CycleManager.phase(day: currentDay, cycleLength: cycleLength, periodLength: periodLength)
    }
    
    var daysUntilNextPeriod: Int {
        CycleManager.daysUntilNextPeriod(day: currentDay, cycleLength: cycleLength)
    }
    
    var cycleProgress: Double {
        CycleManager.cycleProgress(day: currentDay, cycleLength: cycleLength)
    }
    
    var nextPeriodDate: Date {
        CycleManager.nextPeriodDate(lastPeriodStart: lastPeriodStart, cycleLength: cycleLength)
    }
    
    // MARK: - Init
    
    init() {
        // Load from UserDefaults for backward compat (will migrate to SwiftData)
        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            hasCompletedOnboarding = true
        }
        if let savedDate = UserDefaults.standard.object(forKey: "lastPeriodStart") as? Date {
            lastPeriodStart = savedDate
        }
        let savedCycle = UserDefaults.standard.integer(forKey: "cycleLength")
        if savedCycle > 0 { cycleLength = savedCycle }
        let savedPeriod = UserDefaults.standard.integer(forKey: "periodLength")
        if savedPeriod > 0 { periodLength = savedPeriod }
    }
    
    /// Called once when modelContext is available — loads or creates SwiftData preferences
    func loadPreferences() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<UserPreferences>()
        if let prefs = try? context.fetch(descriptor).first {
            // Load from SwiftData
            cycleLength = prefs.cycleLength
            periodLength = prefs.periodLength
            lastPeriodStart = prefs.lastPeriodStart
            hasCompletedOnboarding = prefs.hasCompletedOnboarding
            notifyPeriodReminder = prefs.notifyPeriodReminder
            notifyLogReminder = prefs.notifyLogReminder
            notifyOvulation = prefs.notifyOvulation
            periodReminderDays = prefs.periodReminderDays
        } else if hasCompletedOnboarding {
            // Migrate from UserDefaults to SwiftData
            let prefs = UserPreferences(
                cycleLength: cycleLength,
                periodLength: periodLength,
                lastPeriodStart: lastPeriodStart,
                hasCompletedOnboarding: true
            )
            context.insert(prefs)
            try? context.save()
        }
    }
    
    // MARK: - Actions
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        
        // Save to UserDefaults (backward compat)
        UserDefaults.standard.set(lastPeriodStart, forKey: "lastPeriodStart")
        UserDefaults.standard.set(cycleLength, forKey: "cycleLength")
        UserDefaults.standard.set(periodLength, forKey: "periodLength")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Save to SwiftData
        savePreferences()
        
        // Also create an initial period entry
        logPeriodStart(date: lastPeriodStart)
    }
    
    func savePreferences() {
        guard let context = modelContext else { return }
        
        // Validate: periodLength must be less than cycleLength
        if periodLength >= cycleLength {
            periodLength = min(periodLength, cycleLength - 3)
        }
        
        let descriptor = FetchDescriptor<UserPreferences>()
        if let prefs = try? context.fetch(descriptor).first {
            prefs.cycleLength = cycleLength
            prefs.periodLength = periodLength
            prefs.lastPeriodStart = lastPeriodStart
            prefs.hasCompletedOnboarding = hasCompletedOnboarding
            prefs.notifyPeriodReminder = notifyPeriodReminder
            prefs.notifyLogReminder = notifyLogReminder
            prefs.notifyOvulation = notifyOvulation
            prefs.periodReminderDays = periodReminderDays
        } else {
            let prefs = UserPreferences(
                cycleLength: cycleLength,
                periodLength: periodLength,
                lastPeriodStart: lastPeriodStart,
                hasCompletedOnboarding: hasCompletedOnboarding,
                notifyPeriodReminder: notifyPeriodReminder,
                notifyLogReminder: notifyLogReminder,
                notifyOvulation: notifyOvulation,
                periodReminderDays: periodReminderDays
            )
            context.insert(prefs)
        }
        do {
            try context.save()
        } catch {
            print("CycleGlow: Failed to save preferences: \(error)")
        }
        
        // Reschedule notifications whenever preferences change
        scheduleNotifications()
    }
    
    /// Request notification permission and schedule notifications
    func requestNotificationPermissionIfNeeded() {
        Task {
            let manager = NotificationManager.shared
            await manager.checkAuthorizationStatus()
            if !manager.isAuthorized {
                await manager.requestPermission()
            }
            scheduleNotifications()
        }
    }
    
    /// Reschedule all notifications based on current preferences
    func scheduleNotifications() {
        Task {
            await NotificationManager.shared.rescheduleAll(
                lastPeriodStart: lastPeriodStart,
                cycleLength: cycleLength,
                periodLength: periodLength,
                notifyPeriodReminder: notifyPeriodReminder,
                periodReminderDays: periodReminderDays,
                notifyLogReminder: notifyLogReminder,
                notifyOvulation: notifyOvulation
            )
        }
    }
    
    // MARK: - Daily Log Persistence
    
    func saveLog() {
        guard let context = modelContext else { return }
        
        // Check for existing log today (upsert)
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<PersistedDailyLog>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        
        if let existing = try? context.fetch(descriptor).first {
            // Update existing entry
            existing.mood = todayMood
            existing.skinCondition = todaySkin.rawValue
            existing.energy = todayEnergy
            existing.symptomsList = todaySymptoms.map(\.rawValue).joined(separator: ",")
            existing.notes = todayNotes
        } else {
            // Create new entry
            let entry = PersistedDailyLog(
                date: Date(),
                mood: todayMood,
                skinCondition: todaySkin.rawValue,
                energy: todayEnergy,
                symptomsList: todaySymptoms.map(\.rawValue).joined(separator: ","),
                notes: todayNotes
            )
            context.insert(entry)
        }
        
        do {
            try context.save()
        } catch {
            print("CycleGlow: Failed to save daily log: \(error)")
        }
        
        // Reset notes
        todayNotes = ""
    }
    
    func fetchLogs() -> [PersistedDailyLog] {
        guard let context = modelContext else { return [] }
        var descriptor = FetchDescriptor<PersistedDailyLog>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 90 // last ~3 months
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Period Logging
    
    func logPeriodStart(date: Date) {
        guard let context = modelContext else { return }
        
        // End any ongoing period first
        endOngoingPeriods()
        
        let entry = PeriodEntry(startDate: date)
        context.insert(entry)
        
        // Update last period start
        lastPeriodStart = date
        savePreferences()
        
        try? context.save()
    }
    
    func logPeriodEnd(date: Date) {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<PeriodEntry>(
            predicate: #Predicate { $0.endDate == nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        if let ongoing = try? context.fetch(descriptor).first {
            // Validate: end date must be >= start date
            guard date >= ongoing.startDate else { return }
            ongoing.endDate = date
            do {
                try context.save()
            } catch {
                print("CycleGlow: Failed to save period end: \(error)")
            }
        }
    }
    
    func endOngoingPeriods() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<PeriodEntry>(
            predicate: #Predicate { $0.endDate == nil }
        )
        
        if let ongoing = try? context.fetch(descriptor) {
            for period in ongoing {
                // Auto-end: assume it lasted periodLength days
                period.endDate = Calendar.current.date(byAdding: .day, value: periodLength, to: period.startDate)
            }
            try? context.save()
        }
    }
    
    var hasOngoingPeriod: Bool {
        guard let context = modelContext else { return false }
        let descriptor = FetchDescriptor<PeriodEntry>(
            predicate: #Predicate { $0.endDate == nil }
        )
        return ((try? context.fetchCount(descriptor)) ?? 0) > 0
    }
    
    func fetchPeriods() -> [PeriodEntry] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<PeriodEntry>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Data Export
    
    private static let csvDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    
    private func csvEscape(_ text: String) -> String {
        let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
    
    func exportCSV() -> String {
        let df = Self.csvDateFormatter
        
        var csv = "Date,Cycle Day,Phase,Mood,Skin,Energy,Symptoms,Notes\n"
        for log in fetchLogs().reversed() {
            let dateStr = df.string(from: log.date)
            let day = CycleManager.currentDay(lastPeriodStart: lastPeriodStart, cycleLength: cycleLength)
            let phase = CycleManager.phase(day: day, cycleLength: cycleLength, periodLength: periodLength)
            let symptomsStr = log.symptomsList.replacingOccurrences(of: ",", with: ";")
            csv += "\(dateStr),\(day),\(phase.rawValue),\(log.mood),\(log.skinCondition),\(log.energy),\(csvEscape(symptomsStr)),\(csvEscape(log.notes))\n"
        }
        
        csv += "\nPeriod Start,Period End,Duration (days)\n"
        for period in fetchPeriods().reversed() {
            let start = df.string(from: period.startDate)
            let end = period.endDate.map { df.string(from: $0) } ?? "Ongoing"
            let dur = period.duration.map { "\($0)" } ?? ""
            csv += "\(start),\(end),\(dur)\n"
        }
        
        return csv
    }
}

// MARK: - Supporting Types

enum SkinCondition: String, CaseIterable {
    case clear = "Clear"
    case oily = "Oily"
    case dry = "Dry"
    case breakout = "Breakout"
    
    var icon: String {
        switch self {
        case .clear: return "sparkles"
        case .oily: return "drop.fill"
        case .dry: return "wind"
        case .breakout: return "circle.dotted"
        }
    }
}

enum Symptom: String, CaseIterable, Identifiable {
    case cramps = "Cramps"
    case headache = "Headache"
    case bloating = "Bloating"
    case fatigue = "Fatigue"
    case acne = "Acne"
    case moodSwings = "Mood Swings"
    case backPain = "Back Pain"
    case cravings = "Cravings"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .cramps: return "bolt.fill"
        case .headache: return "brain.head.profile"
        case .bloating: return "circle.fill"
        case .fatigue: return "battery.25"
        case .acne: return "face.dashed"
        case .moodSwings: return "theatermasks.fill"
        case .backPain: return "figure.stand"
        case .cravings: return "fork.knife"
        }
    }
}

struct DailyLogEntry: Identifiable {
    let id = UUID()
    let date: Date
    let mood: Int
    let skin: SkinCondition
    let energy: Int
    let symptoms: Set<Symptom>
    let notes: String
}
