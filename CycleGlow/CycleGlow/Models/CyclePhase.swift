import SwiftUI

enum CyclePhase: String, CaseIterable {
    case menstrual = "Menstrual"
    case follicular = "Follicular"
    case ovulatory = "Ovulatory"
    case luteal = "Luteal"
    
    var color: Color {
        switch self {
        case .menstrual: return Color(hex: "E11D48")
        case .follicular: return Color(hex: "8B5CF6")
        case .ovulatory: return Color(hex: "F59E0B")
        case .luteal: return Color(hex: "EC4899")
        }
    }
    
    var icon: String {
        switch self {
        case .menstrual: return "drop.fill"
        case .follicular: return "leaf.fill"
        case .ovulatory: return "sun.max.fill"
        case .luteal: return "moon.fill"
        }
    }
    
    var dayRange: String {
        switch self {
        case .menstrual: return "Days 1–5"
        case .follicular: return "Days 6–13"
        case .ovulatory: return "Days 14–16"
        case .luteal: return "Days 17–28"
        }
    }
    
    var description: String {
        switch self {
        case .menstrual: return "Your body is shedding the uterine lining. Rest, hydrate, and be gentle with yourself."
        case .follicular: return "Estrogen is rising — energy and mood improve. Great time to try new things."
        case .ovulatory: return "Peak energy and glow. You're at your most social and confident."
        case .luteal: return "Progesterone rises. You may feel more introspective. Prioritize self-care."
        }
    }
    
    var skincareAdvice: [SkincareItem] {
        switch self {
        case .menstrual:
            return [
                SkincareItem(name: "Gentle Cleanser", status: .recommended, reason: "Skin is sensitive — avoid stripping natural oils"),
                SkincareItem(name: "Hyaluronic Acid", status: .recommended, reason: "Deeply hydrating, soothes dry sensitive skin"),
                SkincareItem(name: "Ceramide Moisturizer", status: .recommended, reason: "Repairs skin barrier during vulnerable phase"),
                SkincareItem(name: "Retinol", status: .avoid, reason: "Too harsh for sensitive menstrual skin"),
                SkincareItem(name: "AHA/BHA Exfoliants", status: .avoid, reason: "Can cause irritation and redness"),
                SkincareItem(name: "Vitamin C Serum", status: .caution, reason: "Use low concentration only if tolerated"),
            ]
        case .follicular:
            return [
                SkincareItem(name: "Retinol", status: .recommended, reason: "Skin can handle actives — great time to use"),
                SkincareItem(name: "AHA/BHA Exfoliants", status: .recommended, reason: "Estrogen supports skin renewal"),
                SkincareItem(name: "Vitamin C Serum", status: .recommended, reason: "Brightening works best when skin is resilient"),
                SkincareItem(name: "New Products", status: .recommended, reason: "Best phase to patch-test new skincare"),
                SkincareItem(name: "Heavy Oils", status: .caution, reason: "Skin doesn't need heavy moisture right now"),
            ]
        case .ovulatory:
            return [
                SkincareItem(name: "SPF 50+", status: .recommended, reason: "Peak UV sensitivity — protect your glow"),
                SkincareItem(name: "Lightweight Moisturizer", status: .recommended, reason: "Skin is naturally hydrated — keep it light"),
                SkincareItem(name: "Niacinamide", status: .recommended, reason: "Controls early sebum production"),
                SkincareItem(name: "Heavy Creams", status: .caution, reason: "Can feel greasy — skin doesn't need it"),
            ]
        case .luteal:
            return [
                SkincareItem(name: "Salicylic Acid", status: .recommended, reason: "Prevents hormonal breakouts"),
                SkincareItem(name: "Niacinamide", status: .recommended, reason: "Controls excess oil and reduces inflammation"),
                SkincareItem(name: "Clay Mask", status: .recommended, reason: "Draws out excess sebum weekly"),
                SkincareItem(name: "Tea Tree Oil", status: .recommended, reason: "Spot treatment for emerging breakouts"),
                SkincareItem(name: "Comedogenic Oils", status: .avoid, reason: "Will clog pores — breakout risk is high"),
                SkincareItem(name: "Heavy Moisturizers", status: .avoid, reason: "Excess oil + heavy cream = breakouts"),
            ]
        }
    }
    
    var nutritionAdvice: [NutritionItem] {
        switch self {
        case .menstrual:
            return [
                NutritionItem(name: "Spinach & Lentils", emoji: "🥬", reason: "Iron-rich to replenish blood loss"),
                NutritionItem(name: "Salmon & Turmeric", emoji: "🐟", reason: "Anti-inflammatory, reduces cramps"),
                NutritionItem(name: "Dark Chocolate", emoji: "🍫", reason: "Magnesium eases muscle tension"),
                NutritionItem(name: "Avocado", emoji: "🥑", reason: "Healthy fats + magnesium for recovery"),
                NutritionItem(name: "Berries", emoji: "🫐", reason: "Antioxidants reduce inflammation"),
                NutritionItem(name: "Ginger Tea", emoji: "🫚", reason: "Natural cramp relief"),
            ]
        case .follicular:
            return [
                NutritionItem(name: "Kimchi & Yogurt", emoji: "🥛", reason: "Fermented foods support gut-hormone axis"),
                NutritionItem(name: "Sprouted Foods", emoji: "🌱", reason: "Enzymes support estrogen metabolism"),
                NutritionItem(name: "Chicken & Fish", emoji: "🍗", reason: "Light proteins fuel rising energy"),
                NutritionItem(name: "Flaxseeds", emoji: "🫘", reason: "Phytoestrogens support hormonal balance"),
                NutritionItem(name: "Citrus Fruits", emoji: "🍊", reason: "Vitamin C boosts iron absorption"),
            ]
        case .ovulatory:
            return [
                NutritionItem(name: "Berries & Bell Peppers", emoji: "🫑", reason: "Antioxidants protect peak-energy cells"),
                NutritionItem(name: "Quinoa & Oats", emoji: "🥣", reason: "Fiber supports estrogen detox"),
                NutritionItem(name: "Pumpkin Seeds", emoji: "🎃", reason: "Zinc supports egg quality"),
                NutritionItem(name: "Leafy Greens", emoji: "🥗", reason: "Folate and fiber at peak fertility"),
                NutritionItem(name: "Water", emoji: "💧", reason: "Extra hydration for cervical fluid"),
            ]
        case .luteal:
            return [
                NutritionItem(name: "Sweet Potato", emoji: "🍠", reason: "Complex carbs stabilize mood swings"),
                NutritionItem(name: "Brown Rice", emoji: "🍚", reason: "Steady energy, fights PMS fatigue"),
                NutritionItem(name: "Bananas", emoji: "🍌", reason: "B6 reduces bloating and mood dips"),
                NutritionItem(name: "Chickpeas", emoji: "🫘", reason: "B6 + protein for serotonin production"),
                NutritionItem(name: "Broccoli & Dairy", emoji: "🥦", reason: "Calcium reduces PMS symptoms by 50%"),
                NutritionItem(name: "Dark Chocolate", emoji: "🍫", reason: "Magnesium + serotonin boost"),
            ]
        }
    }
}

struct SkincareItem: Identifiable {
    let id = UUID()
    let name: String
    let status: IngredientStatus
    let reason: String
}

struct NutritionItem: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let reason: String
}

enum IngredientStatus {
    case recommended, caution, avoid
    
    var color: Color {
        switch self {
        case .recommended: return .green
        case .caution: return .yellow
        case .avoid: return .red
        }
    }
    
    var label: String {
        switch self {
        case .recommended: return "Great"
        case .caution: return "Okay"
        case .avoid: return "Avoid"
        }
    }
    
    var icon: String {
        switch self {
        case .recommended: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .avoid: return "xmark.circle.fill"
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
