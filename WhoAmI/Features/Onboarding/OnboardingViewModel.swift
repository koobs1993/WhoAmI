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
    
    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return !firstName.isEmpty && !lastName.isEmpty
        case .personalInfo:
            return !email.isEmpty && email.contains("@")
        default:
            return true
        }
    }
    
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
        
        let profile = UserResearchProfile(
            id: UUID(),
            userId: userId,
            profile: UserProfile(
                id: UUID(),
                userId: userId,
                firstName: firstName,
                lastName: lastName,
                email: email,
                gender: Optional<Gender>.none,
                role: UserRole.user,
                avatarUrl: Optional<String>.none,
                bio: Optional<String>.none,
                phone: Optional<String>.none,
                isActive: true,
                emailConfirmedAt: Optional<Date>.none,
                createdAt: Date(),
                updatedAt: Date()
            ),
            ageRange: nil,
            education: education,
            expectation: nil,
            primaryMotivator: nil,
            activityFrequency: nil,
            lifePlans: [lifePlans],
            completedAt: Date()
        )
        
        try await service.saveUserProfile(profile)
    }
    
    func createUserProfile(firstName: String, lastName: String, email: String) async throws {
        let profile = UserProfile(
            id: UUID(),
            userId: UUID(),
            firstName: firstName,
            lastName: lastName,
            email: email,
            gender: Gender?.none,
            role: UserRole.user,
            avatarUrl: Optional<String>.none,
            bio: Optional<String>.none,
            phone: Optional<String>.none,
            isActive: true,
            emailConfirmedAt: Optional<Date>.none,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await service.createProfile(profile)
    }
    
    func fetchQuestions() async {
        do {
            questions = try await service.fetchQuestions()
        } catch {
            print("Error fetching questions: \(error)")
        }
    }
} 