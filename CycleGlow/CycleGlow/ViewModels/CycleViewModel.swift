import SwiftUI

@Observable
class CycleViewModel {
    var lastPeriodStart: Date = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
    var cycleLength: Int = 28
    var periodLength: Int = 5
    var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    // Daily log
    var todayMood: Int = 3
    var todaySkin: SkinCondition = .clear
    var todayEnergy: Int = 3
    var todaySymptoms: Set<Symptom> = []
    var todayNotes: String = ""
    
    // Log history
    var logHistory: [DailyLogEntry] = []
    
    init() {
        if let savedDate = UserDefaults.standard.object(forKey: "lastPeriodStart") as? Date {
            lastPeriodStart = savedDate
        }
        cycleLength = UserDefaults.standard.integer(forKey: "cycleLength")
        if cycleLength == 0 { cycleLength = 28 }
        periodLength = UserDefaults.standard.integer(forKey: "periodLength")
        if periodLength == 0 { periodLength = 5 }
    }
    
    var currentDay: Int {
        let days = Calendar.current.dateComponents([.day], from: lastPeriodStart, to: Date()).day ?? 0
        let day = (days % cycleLength) + 1
        return max(1, min(day, cycleLength))
    }
    
    var currentPhase: CyclePhase {
        let day = currentDay
        if day <= periodLength { return .menstrual }
        if day <= 13 { return .follicular }
        if day <= 16 { return .ovulatory }
        return .luteal
    }
    
    var daysUntilNextPeriod: Int {
        let remaining = cycleLength - currentDay
        return max(0, remaining)
    }
    
    var cycleProgress: Double {
        Double(currentDay) / Double(cycleLength)
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(lastPeriodStart, forKey: "lastPeriodStart")
        UserDefaults.standard.set(cycleLength, forKey: "cycleLength")
        UserDefaults.standard.set(periodLength, forKey: "periodLength")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = true
    }
    
    func saveLog() {
        let entry = DailyLogEntry(
            date: Date(),
            mood: todayMood,
            skin: todaySkin,
            energy: todayEnergy,
            symptoms: todaySymptoms,
            notes: todayNotes
        )
        logHistory.append(entry)
        // Reset
        todayNotes = ""
    }
}

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
