import SwiftUI

/// Shows past periods and daily log history
struct CycleHistoryView: View {
    @Environment(CycleViewModel.self) private var viewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedTab) {
                    Text("Periods").tag(0)
                    Text("Daily Logs").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    periodHistory
                } else {
                    logHistory
                }
            }
            .background(Theme.backgroundLight.ignoresSafeArea())
            .navigationTitle("History")
        }
    }
    
    // MARK: - Period History
    
    private var periodHistory: some View {
        let periods = viewModel.fetchPeriods()
        
        return Group {
            if periods.isEmpty {
                emptyState(icon: "calendar", message: "No periods logged yet.\nTap \"Log Period\" on the dashboard to start tracking.")
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(periods) { period in
                            periodCard(period)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private func periodCard(_ period: PeriodEntry) -> some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(period.isOngoing ? Theme.rose : Theme.purple)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(period.startDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline.bold())
                    
                    if period.isOngoing {
                        Text("ONGOING")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.rose)
                            .clipShape(Capsule())
                    }
                }
                
                if let end = period.endDate {
                    Text("Ended: \(end.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let dur = period.duration {
                    Text("\(dur) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "drop.fill")
                .foregroundColor(Theme.rose.opacity(0.5))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
    
    // MARK: - Log History
    
    private var logHistory: some View {
        let logs = viewModel.fetchLogs()
        
        return Group {
            if logs.isEmpty {
                emptyState(icon: "square.and.pencil", message: "No daily logs yet.\nGo to the Log tab to track your day.")
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(logs) { log in
                            logCard(log)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private func logCard(_ log: PersistedDailyLog) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(log.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline.bold())
                Spacer()
                Text(moodEmoji(log.mood))
                    .font(.title3)
            }
            
            HStack(spacing: 16) {
                Label("\(log.skin.rawValue)", systemImage: log.skin.icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { level in
                        Image(systemName: level <= log.energy ? "bolt.fill" : "bolt")
                            .font(.caption2)
                            .foregroundColor(level <= log.energy ? Theme.amber : .gray.opacity(0.3))
                    }
                }
            }
            
            if !log.symptoms.isEmpty {
                FlowLayout(spacing: 4) {
                    ForEach(Array(log.symptoms), id: \.rawValue) { symptom in
                        Text(symptom.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Theme.rose.opacity(0.1))
                            .foregroundColor(Theme.rose)
                            .clipShape(Capsule())
                    }
                }
            }
            
            if !log.notes.isEmpty {
                Text(log.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
    
    private func emptyState(icon: String, message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
    
    private func moodEmoji(_ level: Int) -> String {
        switch level {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }
}

/// Simple flow layout for symptom tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 4
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        
        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
