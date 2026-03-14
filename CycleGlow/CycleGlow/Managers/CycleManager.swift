import Foundation

/// Pure cycle calculation logic — no UI state
struct CycleManager {
    
    /// Calculate current cycle day given last period start and cycle length
    static func currentDay(lastPeriodStart: Date, cycleLength: Int) -> Int {
        let days = Calendar.current.dateComponents([.day], from: lastPeriodStart, to: Date()).day ?? 0
        let day = (days % cycleLength) + 1
        return max(1, min(day, cycleLength))
    }
    
    /// Determine cycle phase using proportional boundaries based on actual cycle length
    static func phase(day: Int, cycleLength: Int, periodLength: Int) -> CyclePhase {
        if day <= periodLength { return .menstrual }
        
        // Scale phase boundaries proportionally to cycle length
        // Standard 28-day: follicular ends ~day 13, ovulatory ~14-16, luteal rest
        let ratio = Double(cycleLength) / 28.0
        let follicularEnd = Int(round(13.0 * ratio))
        let ovulatoryEnd = Int(round(16.0 * ratio))
        
        if day <= follicularEnd { return .follicular }
        if day <= ovulatoryEnd { return .ovulatory }
        return .luteal
    }
    
    /// Days until next period
    static func daysUntilNextPeriod(day: Int, cycleLength: Int) -> Int {
        max(0, cycleLength - day)
    }
    
    /// Cycle progress as 0.0 - 1.0
    static func cycleProgress(day: Int, cycleLength: Int) -> Double {
        Double(day) / Double(cycleLength)
    }
    
    /// Predict next period start date
    static func nextPeriodDate(lastPeriodStart: Date, cycleLength: Int) -> Date {
        let day = currentDay(lastPeriodStart: lastPeriodStart, cycleLength: cycleLength)
        let daysLeft = daysUntilNextPeriod(day: day, cycleLength: cycleLength)
        return Calendar.current.date(byAdding: .day, value: daysLeft, to: Date()) ?? Date()
    }
    
    /// Day ranges for a phase given cycle/period length
    static func dayRange(for phase: CyclePhase, cycleLength: Int, periodLength: Int) -> String {
        let ratio = Double(cycleLength) / 28.0
        let follicularEnd = Int(round(13.0 * ratio))
        let ovulatoryEnd = Int(round(16.0 * ratio))
        
        switch phase {
        case .menstrual:
            return "Days 1–\(periodLength)"
        case .follicular:
            return "Days \(periodLength + 1)–\(follicularEnd)"
        case .ovulatory:
            return "Days \(follicularEnd + 1)–\(ovulatoryEnd)"
        case .luteal:
            return "Days \(ovulatoryEnd + 1)–\(cycleLength)"
        }
    }
}
