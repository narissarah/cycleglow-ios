import SwiftUI

struct DashboardView: View {
    @Environment(CycleViewModel.self) private var viewModel
    @State private var showPeriodLog = false
    @State private var showHistory = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.sectionSpacing) {
                    // Cycle Wheel
                    cycleWheel
                    
                    // Period Log Button
                    periodLogButton
                    
                    // Phase Card
                    phaseCard
                    
                    // Quick Stats
                    HStack(spacing: 12) {
                        statCard(title: "Day", value: "\(viewModel.currentDay)", subtitle: "of \(viewModel.cycleLength)", color: viewModel.currentPhase.color)
                        statCard(title: "Next Period", value: "\(viewModel.daysUntilNextPeriod)", subtitle: "days", color: Theme.rose)
                    }
                    .padding(.horizontal)
                    
                    // Skincare Section
                    skincareSection
                    
                    // Nutrition Section
                    nutritionSection
                }
                .padding(.bottom, 20)
            }
            .background(
                Theme.backgroundLight.ignoresSafeArea()
            )
            .navigationTitle("CycleGlow")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(Theme.purple)
                    }
                }
            }
            .sheet(isPresented: $showPeriodLog) {
                PeriodLogView()
                    .environment(viewModel)
            }
            .sheet(isPresented: $showHistory) {
                CycleHistoryView()
                    .environment(viewModel)
            }
        }
    }
    
    // MARK: - Period Log Button
    
    var periodLogButton: some View {
        Button {
            showPeriodLog = true
        } label: {
            HStack {
                Image(systemName: viewModel.hasOngoingPeriod ? "drop.fill" : "plus.circle.fill")
                    .foregroundColor(.white)
                Text(viewModel.hasOngoingPeriod ? "Log Period End" : "Log Period Start")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                viewModel.hasOngoingPeriod
                    ? LinearGradient(colors: [Theme.rose, Theme.pink], startPoint: .leading, endPoint: .trailing)
                    : Theme.primaryGradient
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius))
        }
        .padding(.horizontal)
    }
    
    var cycleWheel: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 12)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: viewModel.cycleProgress)
                .stroke(
                    LinearGradient(
                        colors: [viewModel.currentPhase.color, viewModel.currentPhase.color.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: viewModel.cycleProgress)
            
            VStack(spacing: 4) {
                Image(systemName: viewModel.currentPhase.icon)
                    .font(.title)
                    .foregroundColor(viewModel.currentPhase.color)
                
                Text("Day \(viewModel.currentDay)")
                    .font(.title2.bold())
                    .foregroundColor(Theme.navy)
                
                Text(viewModel.currentPhase.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Cycle day \(viewModel.currentDay) of \(viewModel.cycleLength), \(viewModel.currentPhase.rawValue) phase, \(viewModel.daysUntilNextPeriod) days until next period")
        .padding(.top, 20)
    }
    
    var phaseCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: viewModel.currentPhase.icon)
                    .foregroundColor(viewModel.currentPhase.color)
                Text(viewModel.currentPhase.rawValue + " Phase")
                    .font(.headline)
                Spacer()
                Text(CycleManager.dayRange(for: viewModel.currentPhase, cycleLength: viewModel.cycleLength, periodLength: viewModel.periodLength))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(viewModel.currentPhase.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .padding(.horizontal)
    }
    
    func statCard(title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title.bold())
                .foregroundColor(color)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
    
    // MARK: - Skincare Section
    
    var skincareSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(viewModel.currentPhase.color)
                Text("\(viewModel.currentPhase.rawValue) Phase Skincare")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            HStack(spacing: 16) {
                legendItem(color: .green, label: "Great")
                legendItem(color: .yellow, label: "Okay")
                legendItem(color: .red, label: "Avoid")
            }
            .font(.caption)
            .padding(.horizontal)
            
            ForEach(viewModel.currentPhase.skincareAdvice) { item in
                skincareCard(item)
            }
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
        .clipShape(RoundedRectangle(cornerRadius: Theme.smallCardRadius))
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
    
    // MARK: - Nutrition Section
    
    var nutritionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "leaf.fill")
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
        .clipShape(RoundedRectangle(cornerRadius: Theme.smallCardRadius))
        .padding(.horizontal)
    }
}
