import SwiftUI

/// Result of scanning a skincare product photo via Amazon Nova
struct ProductAnalysis: Identifiable {
    let id = UUID()
    let productName: String
    let ingredients: [AnalyzedIngredient]
    let overallRating: IngredientStatus
    let summary: String
    let timestamp: Date = Date()
}

/// An ingredient extracted from a product, with cycle-phase rating
struct AnalyzedIngredient: Identifiable {
    let id = UUID()
    let name: String
    let status: IngredientStatus
    let reason: String
    let category: IngredientCategory
}

enum IngredientCategory: String {
    case active = "Active"
    case moisturizer = "Moisturizer"
    case exfoliant = "Exfoliant"
    case antiInflammatory = "Anti-inflammatory"
    case fragrance = "Fragrance"
    case preservative = "Preservative"
    case sunscreen = "Sunscreen"
    case other = "Other"
}

/// Known skincare ingredients and their cycle-phase compatibility
struct IngredientDatabase {
    
    /// Maps ingredient keywords to per-phase ratings
    static let entries: [String: [CyclePhase: IngredientStatus]] = [
        // Actives
        "retinol": [.menstrual: .avoid, .follicular: .recommended, .ovulatory: .caution, .luteal: .caution],
        "retinoid": [.menstrual: .avoid, .follicular: .recommended, .ovulatory: .caution, .luteal: .caution],
        "tretinoin": [.menstrual: .avoid, .follicular: .recommended, .ovulatory: .caution, .luteal: .caution],
        "vitamin c": [.menstrual: .caution, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        "ascorbic acid": [.menstrual: .caution, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        "niacinamide": [.menstrual: .recommended, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        "vitamin b3": [.menstrual: .recommended, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        
        // Exfoliants
        "salicylic acid": [.menstrual: .avoid, .follicular: .recommended, .ovulatory: .caution, .luteal: .recommended],
        "glycolic acid": [.menstrual: .avoid, .follicular: .recommended, .ovulatory: .caution, .luteal: .caution],
        "lactic acid": [.menstrual: .caution, .follicular: .recommended, .ovulatory: .recommended, .luteal: .caution],
        "aha": [.menstrual: .avoid, .follicular: .recommended, .ovulatory: .caution, .luteal: .caution],
        "bha": [.menstrual: .avoid, .follicular: .recommended, .ovulatory: .caution, .luteal: .recommended],
        "benzoyl peroxide": [.menstrual: .avoid, .follicular: .caution, .ovulatory: .caution, .luteal: .recommended],
        
        // Moisturizing
        "hyaluronic acid": [.menstrual: .recommended, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        "ceramide": [.menstrual: .recommended, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        "squalane": [.menstrual: .recommended, .follicular: .recommended, .ovulatory: .caution, .luteal: .caution],
        "shea butter": [.menstrual: .recommended, .follicular: .caution, .ovulatory: .avoid, .luteal: .avoid],
        "petroleum": [.menstrual: .recommended, .follicular: .caution, .ovulatory: .avoid, .luteal: .avoid],
        "petrolatum": [.menstrual: .recommended, .follicular: .caution, .ovulatory: .avoid, .luteal: .avoid],
        "mineral oil": [.menstrual: .caution, .follicular: .caution, .ovulatory: .avoid, .luteal: .avoid],
        "coconut oil": [.menstrual: .caution, .follicular: .caution, .ovulatory: .avoid, .luteal: .avoid],
        
        // Anti-inflammatory
        "aloe vera": [.menstrual: .recommended, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        "centella asiatica": [.menstrual: .recommended, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        "tea tree": [.menstrual: .caution, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        "green tea": [.menstrual: .recommended, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        "chamomile": [.menstrual: .recommended, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        
        // Sunscreen
        "spf": [.menstrual: .recommended, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        "zinc oxide": [.menstrual: .recommended, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        "titanium dioxide": [.menstrual: .recommended, .follicular: .recommended, .ovulatory: .recommended, .luteal: .recommended],
        
        // Potentially irritating
        "fragrance": [.menstrual: .avoid, .follicular: .caution, .ovulatory: .caution, .luteal: .avoid],
        "parfum": [.menstrual: .avoid, .follicular: .caution, .ovulatory: .caution, .luteal: .avoid],
        "alcohol denat": [.menstrual: .avoid, .follicular: .caution, .ovulatory: .caution, .luteal: .avoid],
        "essential oil": [.menstrual: .avoid, .follicular: .caution, .ovulatory: .caution, .luteal: .caution],
    ]
    
    /// Reasons for each ingredient
    static let reasons: [String: [CyclePhase: String]] = [
        "retinol": [
            .menstrual: "Too harsh — skin barrier is weakened during menstruation",
            .follicular: "Perfect time! Rising estrogen helps skin tolerate actives",
            .ovulatory: "Use with caution — skin is more sensitive to sun",
            .luteal: "May cause irritation as skin becomes more sensitive"
        ],
        "salicylic acid": [
            .menstrual: "Skin is too sensitive for chemical exfoliants",
            .follicular: "Great for keeping pores clear as skin renews",
            .ovulatory: "Moderate use — don't over-exfoliate at peak",
            .luteal: "Excellent for preventing hormonal breakouts"
        ],
        "hyaluronic acid": [
            .menstrual: "Deeply hydrating — exactly what sensitive skin needs",
            .follicular: "Keeps skin plump and hydrated",
            .ovulatory: "Lightweight hydration for your glow phase",
            .luteal: "Hydrates without adding oil"
        ],
        "niacinamide": [
            .menstrual: "Gentle and soothing — helps repair skin barrier",
            .follicular: "Brightening and pore-minimizing",
            .ovulatory: "Controls early oil production",
            .luteal: "Controls excess sebum and calms inflammation"
        ],
        "fragrance": [
            .menstrual: "Fragrances can trigger sensitivity and irritation now",
            .follicular: "Tolerable but unnecessary — choose fragrance-free when possible",
            .ovulatory: "Less risky but still an irritant",
            .luteal: "Can worsen hormonal skin sensitivity"
        ],
    ]
    
    /// Look up an ingredient's status for the given cycle phase
    static func lookup(_ ingredient: String, phase: CyclePhase) -> (status: IngredientStatus, reason: String, category: IngredientCategory)? {
        let lower = ingredient.lowercased()
        
        for (key, phases) in entries {
            if lower.contains(key) {
                let status = phases[phase] ?? .caution
                let reason = reasons[key]?[phase] ?? defaultReason(for: status, ingredient: ingredient, phase: phase)
                let category = categorize(key)
                return (status, reason, category)
            }
        }
        return nil
    }
    
    static func defaultReason(for status: IngredientStatus, ingredient: String, phase: CyclePhase) -> String {
        switch status {
        case .recommended: return "\(ingredient) works well during the \(phase.rawValue.lowercased()) phase"
        case .caution: return "Use \(ingredient) with care during the \(phase.rawValue.lowercased()) phase"
        case .avoid: return "\(ingredient) may cause issues during the \(phase.rawValue.lowercased()) phase"
        }
    }
    
    static func categorize(_ key: String) -> IngredientCategory {
        let actives = ["retinol", "retinoid", "tretinoin", "vitamin c", "ascorbic acid", "niacinamide", "vitamin b3"]
        let exfoliants = ["salicylic acid", "glycolic acid", "lactic acid", "aha", "bha", "benzoyl peroxide"]
        let moisturizers = ["hyaluronic acid", "ceramide", "squalane", "shea butter", "petroleum", "petrolatum", "mineral oil", "coconut oil"]
        let antiInflammatory = ["aloe vera", "centella asiatica", "tea tree", "green tea", "chamomile"]
        let sunscreen = ["spf", "zinc oxide", "titanium dioxide"]
        let fragrances = ["fragrance", "parfum", "essential oil"]
        
        if actives.contains(key) { return .active }
        if exfoliants.contains(key) { return .exfoliant }
        if moisturizers.contains(key) { return .moisturizer }
        if antiInflammatory.contains(key) { return .antiInflammatory }
        if sunscreen.contains(key) { return .sunscreen }
        if fragrances.contains(key) { return .fragrance }
        return .other
    }
}
