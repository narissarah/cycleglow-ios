import SwiftUI
import Foundation

/// Service to analyze skincare product photos using Amazon Nova via API Gateway
/// For hackathon: includes local fallback analysis when API is unavailable
@Observable
class NovaAPIService {
    
    // MARK: - Configuration
    
    /// API Gateway endpoint URL pointing to Lambda → Bedrock Nova Lite
    /// Set this to your deployed endpoint, or leave empty for local-only analysis
    static let apiEndpoint: String = {
        // Check for environment/config override
        if let url = Bundle.main.object(forInfoDictionaryKey: "NOVA_API_ENDPOINT") as? String, !url.isEmpty {
            return url
        }
        // Default: empty means use local analysis
        return ""
    }()
    
    /// Model ID for Amazon Nova Lite (multimodal)
    static let modelId = "amazon.nova-lite-v1:0"
    
    // MARK: - State
    
    var isAnalyzing = false
    var lastError: String?
    var lastAnalysis: ProductAnalysis?
    
    // MARK: - Analysis
    
    /// Analyze a product photo and return ingredient recommendations for the given cycle phase
    func analyzeProduct(image: UIImage, phase: CyclePhase) async -> ProductAnalysis? {
        isAnalyzing = true
        lastError = nil
        defer { isAnalyzing = false }
        
        // Try Nova API first if endpoint is configured
        if !Self.apiEndpoint.isEmpty {
            if let result = await callNovaAPI(image: image, phase: phase) {
                lastAnalysis = result
                return result
            }
            // Fall through to local analysis on API failure
            print("Nova API call failed, falling back to local analysis")
        }
        
        // Local analysis using ingredient database
        let result = localAnalysis(image: image, phase: phase)
        lastAnalysis = result
        return result
    }
    
    // MARK: - Nova API Call
    
    private func callNovaAPI(image: UIImage, phase: CyclePhase) async -> ProductAnalysis? {
        guard let url = URL(string: Self.apiEndpoint) else { return nil }
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return nil }
        
        let base64Image = imageData.base64EncodedString()
        
        let prompt = """
        Analyze this skincare product photo. Extract:
        1. Product name (from label)
        2. All visible ingredients
        
        Return as JSON:
        {
          "productName": "...",
          "ingredients": ["ingredient1", "ingredient2", ...]
        }
        
        Only return the JSON, no other text.
        """
        
        let requestBody: [String: Any] = [
            "image": base64Image,
            "prompt": prompt,
            "modelId": Self.modelId
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        request.httpBody = httpBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                lastError = "API returned error"
                return nil
            }
            
            return parseNovaResponse(data: data, phase: phase)
        } catch {
            lastError = error.localizedDescription
            return nil
        }
    }
    
    private func parseNovaResponse(data: Data, phase: CyclePhase) -> ProductAnalysis? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        
        // Extract from API Gateway response
        let analysisText = json["analysis"] as? String ?? ""
        
        // Try to parse the JSON from Nova's response
        guard let innerData = analysisText.data(using: .utf8),
              let result = try? JSONSerialization.jsonObject(with: innerData) as? [String: Any] else {
            return nil
        }
        
        let productName = result["productName"] as? String ?? "Unknown Product"
        let ingredientNames = result["ingredients"] as? [String] ?? []
        
        let analyzedIngredients = ingredientNames.compactMap { name -> AnalyzedIngredient? in
            if let lookup = IngredientDatabase.lookup(name, phase: phase) {
                return AnalyzedIngredient(
                    name: name.capitalized,
                    status: lookup.status,
                    reason: lookup.reason,
                    category: lookup.category
                )
            }
            return AnalyzedIngredient(
                name: name.capitalized,
                status: .caution,
                reason: "Unknown ingredient — patch test recommended",
                category: .other
            )
        }
        
        let overall = overallRating(ingredients: analyzedIngredients)
        let summary = generateSummary(productName: productName, ingredients: analyzedIngredients, phase: phase)
        
        return ProductAnalysis(
            productName: productName,
            ingredients: analyzedIngredients,
            overallRating: overall,
            summary: summary
        )
    }
    
    // MARK: - Local Analysis (Demo/Fallback)
    
    /// Performs analysis using the built-in ingredient database
    /// In production, Nova would extract ingredients from the photo
    /// For demo, we simulate with common product types
    func localAnalysis(image: UIImage, phase: CyclePhase) -> ProductAnalysis {
        // Simulate processing time
        let demoProducts = [
            DemoProduct(
                name: "CeraVe Moisturizing Cream",
                ingredients: ["Ceramide", "Hyaluronic Acid", "Petrolatum", "Niacinamide", "Cholesterol"]
            ),
            DemoProduct(
                name: "The Ordinary Niacinamide 10% + Zinc 1%",
                ingredients: ["Niacinamide", "Zinc", "Glycerin", "Hyaluronic Acid"]
            ),
            DemoProduct(
                name: "Paula's Choice 2% BHA Exfoliant",
                ingredients: ["Salicylic Acid", "Green Tea", "Methylpropanediol"]
            ),
            DemoProduct(
                name: "La Roche-Posay Anthelios SPF 50",
                ingredients: ["SPF", "Niacinamide", "Vitamin E", "Glycerin"]
            ),
            DemoProduct(
                name: "The Ordinary Retinol 0.5% in Squalane",
                ingredients: ["Retinol", "Squalane", "Jojoba Oil"]
            ),
            DemoProduct(
                name: "Glow Recipe Watermelon Toner",
                ingredients: ["AHA", "BHA", "Hyaluronic Acid", "Aloe Vera", "Fragrance"]
            ),
        ]
        
        // Pick a random demo product for simulation
        let demo = demoProducts.randomElement()!
        
        let analyzedIngredients = demo.ingredients.map { name -> AnalyzedIngredient in
            if let lookup = IngredientDatabase.lookup(name, phase: phase) {
                return AnalyzedIngredient(
                    name: name,
                    status: lookup.status,
                    reason: lookup.reason,
                    category: lookup.category
                )
            }
            return AnalyzedIngredient(
                name: name,
                status: .caution,
                reason: "Not in database — use with care",
                category: .other
            )
        }
        
        let overall = overallRating(ingredients: analyzedIngredients)
        let summary = generateSummary(productName: demo.name, ingredients: analyzedIngredients, phase: phase)
        
        return ProductAnalysis(
            productName: demo.name,
            ingredients: analyzedIngredients,
            overallRating: overall,
            summary: summary
        )
    }
    
    // MARK: - Helpers
    
    private func overallRating(ingredients: [AnalyzedIngredient]) -> IngredientStatus {
        let avoidCount = ingredients.filter { $0.status == .avoid }.count
        let cautionCount = ingredients.filter { $0.status == .caution }.count
        
        if avoidCount >= 2 { return .avoid }
        if avoidCount >= 1 || cautionCount >= ingredients.count / 2 { return .caution }
        return .recommended
    }
    
    private func generateSummary(productName: String, ingredients: [AnalyzedIngredient], phase: CyclePhase) -> String {
        let avoidCount = ingredients.filter { $0.status == .avoid }.count
        let goodCount = ingredients.filter { $0.status == .recommended }.count
        
        if avoidCount == 0 && goodCount == ingredients.count {
            return "✨ Perfect match for your \(phase.rawValue.lowercased()) phase! All ingredients are skin-friendly right now."
        } else if avoidCount >= 2 {
            return "⚠️ Not ideal for your \(phase.rawValue.lowercased()) phase. \(avoidCount) ingredients may cause irritation."
        } else if avoidCount == 1 {
            let badOne = ingredients.first { $0.status == .avoid }?.name ?? "an ingredient"
            return "🔶 Mostly okay, but \(badOne) isn't great during your \(phase.rawValue.lowercased()) phase."
        } else {
            return "👍 Generally suitable for your \(phase.rawValue.lowercased()) phase with minor considerations."
        }
    }
}

private struct DemoProduct {
    let name: String
    let ingredients: [String]
}
