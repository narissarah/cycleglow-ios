import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "circle.grid.3x3.fill")
                }
            
            SkincareView()
                .tabItem {
                    Label("Skincare", systemImage: "sparkles")
                }
            
            ProductScannerView()
                .tabItem {
                    Label("Scanner", systemImage: "camera.viewfinder")
                }
            
            NutritionView()
                .tabItem {
                    Label("Nutrition", systemImage: "leaf.fill")
                }
            
            HormoneChartView()
                .tabItem {
                    Label("Hormones", systemImage: "chart.xyaxis.line")
                }
            
            LogView()
                .tabItem {
                    Label("Log", systemImage: "square.and.pencil")
                }
        }
        .tint(Color(hex: "8B5CF6"))
    }
}
