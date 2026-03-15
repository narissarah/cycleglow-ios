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
                                                ? Theme.purple.opacity(0.2)
                                                : Color.clear
                                        )
                                        .clipShape(Circle())
                                }
                                .accessibilityLabel("Mood level \(level) of 5, \(moodLabel(level))")
                                .accessibilityAddTraits(viewModel.todayMood == level ? .isSelected : [])
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
                                            ? Theme.pink.opacity(0.2)
                                            : Color.gray.opacity(0.08)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .foregroundColor(
                                    viewModel.todaySkin == condition
                                        ? Theme.pink
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
                                                ? Theme.amber
                                                : .gray.opacity(0.3)
                                        )
                                }
                                .accessibilityLabel("Energy level \(level) of 5")
                                .accessibilityAddTraits(level <= viewModel.todayEnergy ? .isSelected : [])
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
                                            ? Theme.rose.opacity(0.15)
                                            : Color.gray.opacity(0.08)
                                    )
                                    .foregroundColor(
                                        viewModel.todaySymptoms.contains(symptom)
                                            ? Theme.rose
                                            : .secondary
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .accessibilityLabel("\(symptom.rawValue)")
                                .accessibilityAddTraits(viewModel.todaySymptoms.contains(symptom) ? .isSelected : [])
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
                            showSaved
                                ? Theme.successGradient
                                : Theme.primaryGradient
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius))
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .background(
                Theme.backgroundLight.ignoresSafeArea()
            )
            .navigationTitle("Daily Log")
        }
    }
    
    func logSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(Theme.purple)
                Text(title)
                    .font(.subheadline.bold())
            }
            content()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
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
    
    func moodLabel(_ level: Int) -> String {
        switch level {
        case 1: return "very sad"
        case 2: return "sad"
        case 3: return "neutral"
        case 4: return "happy"
        case 5: return "very happy"
        default: return "neutral"
        }
    }
}
