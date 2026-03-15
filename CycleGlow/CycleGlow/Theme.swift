import SwiftUI

/// Centralized design system for CycleGlow
/// All colors, gradients, and spacing tokens live here
/// Supports both light and dark mode with adaptive colors
enum Theme {
    
    // MARK: - Primary Colors (Adaptive)
    
    static let purple = Color.adaptive(light: "8B5CF6", dark: "A78BFA")
    static let pink = Color.adaptive(light: "EC4899", dark: "F472B6")
    static let rose = Color.adaptive(light: "E11D48", dark: "FB7185")
    static let amber = Color.adaptive(light: "F59E0B", dark: "FBBF24")
    static let navy = Color.adaptive(light: "1E1B4B", dark: "C7D2FE")
    static let blue = Color.adaptive(light: "3B82F6", dark: "60A5FA")
    static let green = Color.adaptive(light: "10B981", dark: "34D399")
    
    // MARK: - Surface Colors (Adaptive)
    
    static let cardBackground = Color.adaptive(
        light: UIColor.white,
        dark: UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1)
    )
    
    static let surfaceBackground = Color.adaptive(
        light: UIColor(red: 0.96, green: 0.95, blue: 1.0, alpha: 1),
        dark: UIColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 1)
    )
    
    static let textPrimary = Color.adaptive(
        light: UIColor(red: 0.12, green: 0.11, blue: 0.29, alpha: 1),
        dark: UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
    )
    
    static let textSecondary = Color.adaptive(
        light: UIColor.secondaryLabel,
        dark: UIColor.secondaryLabel
    )
    
    // MARK: - Gradients (Adaptive)
    
    static let primaryGradient = LinearGradient(
        colors: [purple, pink],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static var backgroundLight: LinearGradient {
        LinearGradient(
            colors: [
                Color.adaptive(light: "F5F3FF", dark: "1A1A2E"),
                Color.adaptive(light: "FFF7ED", dark: "16213E")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var backgroundPink: LinearGradient {
        LinearGradient(
            colors: [
                Color.adaptive(light: "F5F3FF", dark: "1A1A2E"),
                Color.adaptive(light: "FFF1F2", dark: "2D1B2E")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var backgroundRose: LinearGradient {
        LinearGradient(
            colors: [
                Color.adaptive(light: "FDF2F8", dark: "2D1B2E"),
                Color.adaptive(light: "F5F3FF", dark: "1A1A2E")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static let successGradient = LinearGradient(
        colors: [green, green.opacity(0.8)],
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

// MARK: - Adaptive Color Extension

extension Color {
    /// Create a color that adapts to light/dark mode using hex strings
    static func adaptive(light: String, dark: String) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
    
    /// Create a color that adapts to light/dark mode using UIColors
    static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgb & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}
