import SwiftUI

/// Centralized design system for CycleGlow
/// All colors, gradients, and spacing tokens live here
enum Theme {
    
    // MARK: - Primary Colors
    
    static let purple = Color(hex: "8B5CF6")
    static let pink = Color(hex: "EC4899")
    static let rose = Color(hex: "E11D48")
    static let amber = Color(hex: "F59E0B")
    static let navy = Color(hex: "1E1B4B")
    static let blue = Color(hex: "3B82F6")
    static let green = Color(hex: "10B981")
    
    // MARK: - Gradients
    
    static let primaryGradient = LinearGradient(
        colors: [purple, pink],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let backgroundLight = LinearGradient(
        colors: [Color(hex: "F5F3FF"), Color(hex: "FFF7ED")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let backgroundPink = LinearGradient(
        colors: [Color(hex: "F5F3FF"), Color(hex: "FFF1F2")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let backgroundRose = LinearGradient(
        colors: [Color(hex: "FDF2F8"), Color(hex: "F5F3FF")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let successGradient = LinearGradient(
        colors: [.green, .green.opacity(0.8)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - Card Styling
    
    static let cardRadius: CGFloat = 16
    static let smallCardRadius: CGFloat = 12
    static let buttonRadius: CGFloat = 16
    
    // MARK: - Spacing
    
    static let sectionSpacing: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let horizontalPadding: CGFloat = 16
}
