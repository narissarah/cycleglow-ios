import SwiftUI

struct OnboardingView: View {
    @Environment(CycleViewModel.self) private var viewModel
    @State private var step = 0
    
    var body: some View {
        @Bindable var vm = viewModel
        
        ZStack {
            LinearGradient(
                colors: [Color(hex: "F5F3FF"), Color(hex: "FFF1F2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
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
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "8B5CF6"), Color(hex: "EC4899")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "8B5CF6"), Color(hex: "EC4899")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("CycleGlow")
                .font(.largeTitle.bold())
                .foregroundColor(Color(hex: "1E1B4B"))
            
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
                .foregroundColor(Color(hex: "E11D48"))
            
            Text("When did your last period start?")
                .font(.title3.bold())
                .foregroundColor(Color(hex: "1E1B4B"))
            
            DatePicker("", selection: $vm.lastPeriodStart, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                .tint(Color(hex: "8B5CF6"))
        }
    }
    
    var cycleLengthStep: some View {
        @Bindable var vm = viewModel
        return VStack(spacing: 24) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "8B5CF6"))
            
            Text("About your cycle")
                .font(.title3.bold())
                .foregroundColor(Color(hex: "1E1B4B"))
            
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
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 30)
        }
    }
}
