import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(CycleViewModel.self) private var viewModel
    @State private var showExportSheet = false
    @State private var exportText = ""
    @State private var showResetAlert = false
    @State private var showSavedBanner = false
    
    var body: some View {
        @Bindable var vm = viewModel
        
        NavigationStack {
            List {
                // MARK: - Cycle Settings
                Section {
                    DatePicker(
                        "Last Period Start",
                        selection: $vm.lastPeriodStart,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .tint(Theme.purple)
                    
                    Stepper("Cycle Length: \(viewModel.cycleLength) days", value: $vm.cycleLength, in: 21...40)
                    
                    Stepper("Period Length: \(viewModel.periodLength) days", value: $vm.periodLength, in: 2...10)
                } header: {
                    Label("Cycle", systemImage: "arrow.triangle.2.circlepath")
                } footer: {
                    Text("Changes are saved automatically.")
                }
                
                // MARK: - Notifications
                Section {
                    Toggle("Period Reminder", isOn: $vm.notifyPeriodReminder)
                    
                    if viewModel.notifyPeriodReminder {
                        Stepper("Remind \(viewModel.periodReminderDays) days before", value: $vm.periodReminderDays, in: 1...7)
                    }
                    
                    Toggle("Daily Log Reminder", isOn: $vm.notifyLogReminder)
                    Toggle("Ovulation Alert", isOn: $vm.notifyOvulation)
                } header: {
                    Label("Notifications", systemImage: "bell.fill")
                }
                
                // MARK: - Data
                Section {
                    Button {
                        exportText = viewModel.exportCSV()
                        showExportSheet = true
                    } label: {
                        Label("Export Data (CSV)", systemImage: "square.and.arrow.up")
                    }
                } header: {
                    Label("Data", systemImage: "externaldrive.fill")
                }
                
                // MARK: - About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Made with")
                        Spacer()
                        Text("💜 SwiftUI + SwiftData")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Label("About", systemImage: "info.circle")
                }
                
                // MARK: - Danger Zone
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                    }
                } footer: {
                    Text("Resets onboarding. Your logs and period data are kept.")
                }
            }
            .navigationTitle("Settings")
            .tint(Theme.purple)
            .onChange(of: viewModel.cycleLength) { _, _ in viewModel.savePreferences() }
            .onChange(of: viewModel.periodLength) { _, _ in viewModel.savePreferences() }
            .onChange(of: viewModel.lastPeriodStart) { _, _ in viewModel.savePreferences() }
            .onChange(of: viewModel.notifyPeriodReminder) { _, newValue in
                if newValue { viewModel.requestNotificationPermissionIfNeeded() }
                viewModel.savePreferences()
            }
            .onChange(of: viewModel.notifyLogReminder) { _, newValue in
                if newValue { viewModel.requestNotificationPermissionIfNeeded() }
                viewModel.savePreferences()
            }
            .onChange(of: viewModel.notifyOvulation) { _, newValue in
                if newValue { viewModel.requestNotificationPermissionIfNeeded() }
                viewModel.savePreferences()
            }
            .onChange(of: viewModel.periodReminderDays) { _, _ in viewModel.savePreferences() }
            .alert("Reset Onboarding?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.hasCompletedOnboarding = false
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    viewModel.savePreferences()
                }
            } message: {
                Text("You'll see the onboarding flow again. Your existing data is preserved.")
            }
            .sheet(isPresented: $showExportSheet) {
                ExportSheetView(csvText: exportText)
            }
        }
    }
}

/// Sheet to share/save exported CSV
struct ExportSheetView: View {
    let csvText: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(csvText)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Export Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(
                        item: csvText,
                        preview: SharePreview("CycleGlow Data Export", image: Image(systemName: "doc.text"))
                    )
                }
            }
        }
    }
}
