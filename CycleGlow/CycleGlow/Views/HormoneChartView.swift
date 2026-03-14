import SwiftUI
import Charts

struct HormoneChartView: View {
    @Environment(CycleViewModel.self) private var viewModel
    @State private var selectedDay: Int?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Main chart
                    Chart {
                        ForEach(HormoneData.cycle) { point in
                            LineMark(
                                x: .value("Day", point.day),
                                y: .value("Level", point.estrogen)
                            )
                            .foregroundStyle(Theme.pink)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                        .symbol(.circle)
                        .symbolSize(0)
                        
                        ForEach(HormoneData.cycle) { point in
                            LineMark(
                                x: .value("Day", point.day),
                                y: .value("Level", point.progesterone)
                            )
                            .foregroundStyle(Theme.purple)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                        
                        ForEach(HormoneData.cycle) { point in
                            LineMark(
                                x: .value("Day", point.day),
                                y: .value("Level", point.lh)
                            )
                            .foregroundStyle(Theme.blue)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                        
                        ForEach(HormoneData.cycle) { point in
                            LineMark(
                                x: .value("Day", point.day),
                                y: .value("Level", point.fsh)
                            )
                            .foregroundStyle(Theme.green)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                        
                        // Current day marker
                        RuleMark(x: .value("Today", viewModel.currentDay))
                            .foregroundStyle(.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                            .annotation(position: .top) {
                                Text("Today")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                    }
                    .frame(height: 250)
                    .padding()
                    .chartXScale(domain: 1...28)
                    .chartXAxis {
                        AxisMarks(values: [1, 5, 10, 14, 17, 21, 28]) { _ in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                    
                    // Legend
                    VStack(spacing: 8) {
                        HStack(spacing: 20) {
                            legendDot(color: Theme.pink, label: "Estrogen")
                            legendDot(color: Theme.purple, label: "Progesterone")
                        }
                        HStack(spacing: 20) {
                            legendDot(color: Theme.blue, label: "LH")
                            legendDot(color: Theme.green, label: "FSH")
                        }
                    }
                    .font(.caption)
                    
                    // Phase breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cycle Phases")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(CyclePhase.allCases, id: \.rawValue) { phase in
                            HStack(spacing: 12) {
                                Image(systemName: phase.icon)
                                    .foregroundColor(phase.color)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(phase.rawValue)
                                            .font(.subheadline.bold())
                                        if phase == viewModel.currentPhase {
                                            Text("CURRENT")
                                                .font(.caption2.bold())
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(phase.color)
                                                .clipShape(Capsule())
                                        }
                                    }
                                    Text(CycleManager.dayRange(for: phase, cycleLength: viewModel.cycleLength, periodLength: viewModel.periodLength))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                phase == viewModel.currentPhase
                                    ? phase.color.opacity(0.08)
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Theme.smallCardRadius))
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .background(
                Theme.backgroundRose.ignoresSafeArea()
            )
            .navigationTitle("Hormones")
        }
    }
    
    func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).foregroundColor(.secondary)
        }
    }
}
