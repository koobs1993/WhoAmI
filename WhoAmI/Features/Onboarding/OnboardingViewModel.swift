import Foundation
import Supabase

enum OnboardingStepScreen {
    case welcome
    case personalInfo
    case education
    case lifePlans
    case finish
}

@MainActor
class OnboardingViewModel: ObservableObject {
    private let supabase: SupabaseClient
    private let service: OnboardingService
    private let userId: UUID
    
    @Published var currentStep: OnboardingStepScreen = .welcome
    @Published var isLoading = false
    @Published var error: Error?
    @Published var questions: [OnboardingQuestion] = []
    @Published var email = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var education: Education?
    @Published var lifePlans = ""
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
        self.service = OnboardingService(supabase: supabase)
        self.userId = UUID() // This should be set from auth session
    }
    
    func nextStep() {
        switch currentStep {
        case .welcome:
            currentStep = .personalInfo
        case .personalInfo:
            currentStep = .education
        case .education:
            currentStep = .lifePlans
        case .lifePlans:
            currentStep = .finish
        case .finish:
            break
        }
    }
    
    func previousStep() {
        switch currentStep {
        case .welcome:
            break
        case .personalInfo:
            currentStep = .welcome
        case .education:
            currentStep = .personalInfo
        case .lifePlans:
            currentStep = .education
        case .finish:
            currentStep = .lifePlans
        }
    }
    
    func loadQuestions() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            questions = try await service.fetchQuestions()
        } catch {
            self.error = error
            throw error
        }
    }
    
    func finishOnboarding() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Add your onboarding completion logic here
    }
} 