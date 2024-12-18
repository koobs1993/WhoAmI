import Foundation
import Supabase

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var error: Error?
    @Published var questions: [WhoAmI.OnboardingQuestion] = []
    @Published var currentStep: OnboardingStep = .welcome
    @Published var email = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var gender: Gender?
    @Published var role: UserRole = .student
    @Published var bio = ""
    @Published var phone = ""
    @Published var education: WhoAmI.Education?
    @Published var lifePlans = ""
    
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
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
    
    func createProfile() async throws {
        let profile = UserProfile(
            id: UUID(),
            userId: UUID(),
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarUrl: "",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await supabase.database
            .from("profiles")
            .insert(profile)
            .execute()
    }
}

enum OnboardingError: LocalizedError {
    case userNotAuthenticated
    case invalidProfile
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User is not authenticated"
        case .invalidProfile:
            return "Invalid profile data"
        case .saveFailed:
            return "Failed to save profile"
        }
    }
} 