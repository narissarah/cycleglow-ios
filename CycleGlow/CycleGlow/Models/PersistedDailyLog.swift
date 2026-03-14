import Foundation
import SwiftData

/// Persisted daily log entry using SwiftData
@Model
final class PersistedDailyLog {
    var date: Date
    var mood: Int
    var skinCondition: String  // SkinCondition rawValue
    var energy: Int
    var symptomsList: String   // comma-separated Symptom rawValues
    var notes: String
    
    init(date: Date, mood: Int, skinCondition: String, energy: Int, symptomsList: String, notes: String) {
        self.date = date
        self.mood = mood
        self.skinCondition = skinCondition
        self.energy = energy
        self.symptomsList = symptomsList
        self.notes = notes
    }
    
    /// Convert from in-memory log entry
    convenience init(from entry: DailyLogEntry) {
        self.init(
            date: entry.date,
            mood: entry.mood,
            skinCondition: entry.skin.rawValue,
            energy: entry.energy,
            symptomsList: entry.symptoms.map(\.rawValue).joined(separator: ","),
            notes: entry.notes
        )
    }
    
    /// Parsed skin condition
    var skin: SkinCondition {
        SkinCondition(rawValue: skinCondition) ?? .clear
    }
    
    /// Parsed symptoms set
    var symptoms: Set<Symptom> {
        guard !symptomsList.isEmpty else { return [] }
        let parsed = symptomsList.split(separator: ",").compactMap { Symptom(rawValue: String($0)) }
        return Set(parsed)
    }
}
