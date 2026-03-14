import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ProductScannerView()
                .tabItem {
                    Label("Scanner", systemImage: "camera.viewfinder")
                }
            
            HormoneChartView()
                .tabItem {
                    Label("Hormones", systemImage: "chart.xyaxis.line")
                }
            
            LogView()
                .tabItem {
                    Label("Log", systemImage: "square.and.pencil")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Theme.purple)
    }
}
