import SwiftUI

struct OnboardingView: View {
    @Environment(CycleViewModel.self) private var viewModel
    @State private var step = 0
    
    var body: some View {
        @Bindable var vm = viewModel
        
        ZStack {
            Theme.backgroundPink.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                if step == 0 {
                    welcomeStep
                } else if step == 1 {
                    periodDateStep
                } else {
                    cycleLengthStep
                }
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 12) {
                    if step > 0 {
                        Button {
                            withAnimation { step -= 1 }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundColor(Theme.purple)
                                .frame(width: 50, height: 50)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    Button {
                        if step < 2 {
                            withAnimation { step += 1 }
                        } else {
                            viewModel.completeOnboarding()
                        }
                    } label: {
                        Text(step < 2 ? "Continue" : "Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    var welcomeStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(Theme.primaryGradient)
            
            Text("CycleGlow")
                .font(.largeTitle.bold())
                .foregroundColor(Theme.navy)
            
            Text("AI-powered skincare & nutrition\nfor every phase of your cycle")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    var periodDateStep: some View {
        @Bindable var vm = viewModel
        return VStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 40))
                .foregroundColor(Theme.rose)
            
            Text("When did your last period start?")
                .font(.title3.bold())
                .foregroundColor(Theme.navy)
            
            DatePicker("", selection: $vm.lastPeriodStart, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                .tint(Theme.purple)
        }
    }
    
    var cycleLengthStep: some View {
        @Bindable var vm = viewModel
        return VStack(spacing: 24) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 40))
                .foregroundColor(Theme.purple)
            
            Text("About your cycle")
                .font(.title3.bold())
                .foregroundColor(Theme.navy)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Cycle Length")
                        .foregroundColor(.secondary)
                    Spacer()
                    Stepper("\(viewModel.cycleLength) days", value: $vm.cycleLength, in: 21...40)
                }
                
                HStack {
                    Text("Period Length")
                        .foregroundColor(.secondary)
                    Spacer()
                    Stepper("\(viewModel.periodLength) days", value: $vm.periodLength, in: 2...10)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
            .padding(.horizontal, 30)
        }
    }
}
