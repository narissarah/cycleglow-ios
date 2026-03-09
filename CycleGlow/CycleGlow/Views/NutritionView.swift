import SwiftUI

struct NutritionView: View {
    @Environment(CycleViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: viewModel.currentPhase.icon)
                            .foregroundColor(viewModel.currentPhase.color)
                        Text("\(viewModel.currentPhase.rawValue) Phase Nutrition")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ForEach(viewModel.currentPhase.nutritionAdvice) { item in
                        nutritionCard(item)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "F0FDF4"), Color(hex: "FFF7ED")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Nutrition")
        }
    }
    
    func nutritionCard(_ item: NutritionItem) -> some View {
        HStack(spacing: 12) {
            Text(item.emoji)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline.bold())
                Text(item.reason)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}
