import SwiftUI

@main
struct CycleGlowApp: App {
    @State private var viewModel = CycleViewModel()
    
    var body: some Scene {
        WindowGroup {
            if viewModel.hasCompletedOnboarding {
                MainTabView()
                    .environment(viewModel)
            } else {
                OnboardingView()
                    .environment(viewModel)
            }
        }
    }
}
