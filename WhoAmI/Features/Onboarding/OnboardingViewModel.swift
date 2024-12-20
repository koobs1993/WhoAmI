import SwiftUI
import Supabase

@MainActor
class OnboardingViewModel: ObservableObject {
    private let supabase: SupabaseClient
    
    @Published var profile = OnboardingProfile(id: UUID(), firstName: "", lastName: "", email: "")
    @Published var currentStep = 0
    @Published var showError = false
    @Published var errorMessage: String?
    
    let totalSteps = 5
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func createProfile() async throws {
        // Validate required fields
        guard !profile.firstName.isEmpty else { throw OnboardingError.missingFirstName }
        guard !profile.lastName.isEmpty else { throw OnboardingError.missingLastName }
        guard !profile.email.isEmpty else { throw OnboardingError.missingEmail }
        
        // Create user profile
        let userProfile = UserProfile(
            id: UUID(),
            firstName: profile.firstName,
            lastName: profile.lastName,
            email: profile.email,
            avatarUrl: nil,
            bio: profile.bio,
            settings: UserSettings.default,
            stats: nil,
            subscription: nil,
            devices: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let _: PostgrestResponse<UserProfile> = try await supabase
            .from("profiles")
            .insert(userProfile)
            .execute()
    }
}

enum OnboardingError: LocalizedError {
    case missingFirstName
    case missingLastName
    case missingEmail
    
    var errorDescription: String? {
        switch self {
        case .missingFirstName:
            return "Please enter your first name"
        case .missingLastName:
            return "Please enter your last name"
        case .missingEmail:
            return "Please enter your email"
        }
    }
}
