import Foundation
import SwiftData

// MARK: - Schema V1 (Initial Release)

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [UserPreferences.self, PersistedDailyLog.self, PeriodEntry.self]
    }
}

// MARK: - Migration Plan

enum CycleGlowMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self]
    }
    
    static var stages: [MigrationStage] {
        // No migrations yet — this is the initial version.
        // When adding SchemaV2, add a migration stage here:
        // .lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self)
        []
    }
}
