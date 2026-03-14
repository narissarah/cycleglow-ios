import SwiftUI

/// View for logging period start/end dates from the dashboard
struct PeriodLogView: View {
    @Environment(CycleViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var periodDate = Date()
    @State private var isStarting = true
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Toggle: starting or ending
                Picker("Period Status", selection: $isStarting) {
                    Text("Period Started").tag(true)
                    Text("Period Ended").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Date picker
                VStack(spacing: 8) {
                    Image(systemName: isStarting ? "drop.fill" : "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(isStarting ? Theme.rose : Theme.green)
                    
                    Text(isStarting ? "When did your period start?" : "When did your period end?")
                        .font(.headline)
                }
                .padding(.top)
                
                DatePicker(
                    "",
                    selection: $periodDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Theme.purple)
                .padding(.horizontal)
                
                Spacer()
                
                // Log button
                Button {
                    if isStarting {
                        viewModel.logPeriodStart(date: periodDate)
                    } else {
                        viewModel.logPeriodEnd(date: periodDate)
                    }
                    showConfirmation = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        dismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: showConfirmation ? "checkmark.circle.fill" : "calendar.badge.plus")
                        Text(showConfirmation ? "Logged!" : "Log \(isStarting ? "Start" : "End")")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        showConfirmation
                            ? Theme.successGradient
                            : Theme.primaryGradient
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius))
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Log Period")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
