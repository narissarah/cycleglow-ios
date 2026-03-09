import SwiftUI

struct SkincareView: View {
    @Environment(CycleViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Phase header
                    HStack {
                        Image(systemName: viewModel.currentPhase.icon)
                            .foregroundColor(viewModel.currentPhase.color)
                        Text("\(viewModel.currentPhase.rawValue) Phase Skincare")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Traffic light legend
                    HStack(spacing: 16) {
                        legendItem(color: .green, label: "Great")
                        legendItem(color: .yellow, label: "Okay")
                        legendItem(color: .red, label: "Avoid")
                    }
                    .font(.caption)
                    .padding(.horizontal)
                    
                    // Skincare items
                    ForEach(viewModel.currentPhase.skincareAdvice) { item in
                        skincareCard(item)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "F5F3FF"), Color(hex: "FFF1F2")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Skincare")
        }
    }
    
    func skincareCard(_ item: SkincareItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.status.icon)
                .foregroundColor(item.status.color)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline.bold())
                Text(item.reason)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(item.status.label)
                .font(.caption2.bold())
                .foregroundColor(item.status.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(item.status.color.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}
