import SwiftUI

struct LogView: View {
    @Environment(CycleViewModel.self) private var viewModel
    @State private var showSaved = false
    
    var body: some View {
        @Bindable var vm = viewModel
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Mood
                    logSection(title: "Mood", icon: "face.smiling") {
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { level in
                                Button {
                                    viewModel.todayMood = level
                                } label: {
                                    Text(moodEmoji(level))
                                        .font(.title2)
                                        .padding(8)
                                        .background(
                                            viewModel.todayMood == level
                                                ? Color(hex: "8B5CF6").opacity(0.2)
                                                : Color.clear
                                        )
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    
                    // Skin
                    logSection(title: "Skin Condition", icon: "sparkles") {
                        HStack(spacing: 8) {
                            ForEach(SkinCondition.allCases, id: \.rawValue) { condition in
                                Button {
                                    viewModel.todaySkin = condition
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: condition.icon)
                                            .font(.title3)
                                        Text(condition.rawValue)
                                            .font(.caption2)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        viewModel.todaySkin == condition
                                            ? Color(hex: "EC4899").opacity(0.2)
                                            : Color.gray.opacity(0.08)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .foregroundColor(
                                    viewModel.todaySkin == condition
                                        ? Color(hex: "EC4899")
                                        : .secondary
                                )
                            }
                        }
                    }
                    
                    // Energy
                    logSection(title: "Energy Level", icon: "bolt.fill") {
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { level in
                                Button {
                                    viewModel.todayEnergy = level
                                } label: {
                                    Image(systemName: level <= viewModel.todayEnergy ? "bolt.fill" : "bolt")
                                        .font(.title3)
                                        .foregroundColor(
                                            level <= viewModel.todayEnergy
                                                ? Color(hex: "F59E0B")
                                                : .gray.opacity(0.3)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Symptoms
                    logSection(title: "Symptoms", icon: "list.bullet") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(Symptom.allCases) { symptom in
                                Button {
                                    if viewModel.todaySymptoms.contains(symptom) {
                                        viewModel.todaySymptoms.remove(symptom)
                                    } else {
                                        viewModel.todaySymptoms.insert(symptom)
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: symptom.icon)
                                            .font(.caption)
                                        Text(symptom.rawValue)
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        viewModel.todaySymptoms.contains(symptom)
                                            ? Color(hex: "E11D48").opacity(0.15)
                                            : Color.gray.opacity(0.08)
                                    )
                                    .foregroundColor(
                                        viewModel.todaySymptoms.contains(symptom)
                                            ? Color(hex: "E11D48")
                                            : .secondary
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    
                    // Notes
                    logSection(title: "Notes", icon: "note.text") {
                        TextField("How are you feeling today?", text: $vm.todayNotes, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(Color.gray.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Save button
                    Button {
                        viewModel.saveLog()
                        showSaved = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSaved = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: showSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                            Text(showSaved ? "Saved!" : "Save Today's Log")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: showSaved
                                    ? [.green, .green.opacity(0.8)]
                                    : [Color(hex: "8B5CF6"), Color(hex: "EC4899")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "F5F3FF"), Color(hex: "FFF7ED")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Daily Log")
        }
    }
    
    func logSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "8B5CF6"))
                Text(title)
                    .font(.subheadline.bold())
            }
            content()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    func moodEmoji(_ level: Int) -> String {
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
