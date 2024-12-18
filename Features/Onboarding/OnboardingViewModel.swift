class OnboardingViewModel: ObservableObject {
    // ... existing properties
    
    func goBack() {
        switch currentStep {
        case .profile: currentStep = .welcome
        case .interests: currentStep = .profile
        case .complete: currentStep = .interests
        default: break
        }
    }
} 