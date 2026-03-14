import Foundation
import SwiftData

/// A recorded period (start + optional end date)
@Model
final class PeriodEntry {
    var startDate: Date
    var endDate: Date?
    var notes: String
    
    init(startDate: Date, endDate: Date? = nil, notes: String = "") {
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
    }
    
    /// Duration in days (nil if period is ongoing)
    var duration: Int? {
        guard let end = endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: startDate, to: end).day.map { $0 + 1 }
    }
    
    var isOngoing: Bool {
        endDate == nil
    }
}
