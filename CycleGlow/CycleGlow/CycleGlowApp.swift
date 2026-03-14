import SwiftUI
import SwiftData

@main
struct CycleGlowApp: App {
    @State private var viewModel = CycleViewModel()
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                UserPreferences.self,
                PersistedDailyLog.self,
                PeriodEntry.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if viewModel.hasCompletedOnboarding {
                MainTabView()
                    .environment(viewModel)
                    .modelContainer(modelContainer)
                    .onAppear {
                        viewModel.modelContext = modelContainer.mainContext
                        viewModel.loadPreferences()
                    }
            } else {
                OnboardingView()
                    .environment(viewModel)
                    .modelContainer(modelContainer)
                    .onAppear {
                        viewModel.modelContext = modelContainer.mainContext
                    }
            }
        }
    }
}
