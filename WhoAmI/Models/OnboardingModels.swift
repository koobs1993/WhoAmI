import Foundation

// MARK: - Onboarding Step
enum OnboardingStep: Int, CaseIterable {
    case welcome
    case personalInfo
    case education
    case lifePlans
    case subscription
    case complete
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .personalInfo:
            return "Personal Information"
        case .education:
            return "Education"
        case .lifePlans:
            return "Life Plans"
        case .subscription:
            return "Subscription"
        case .complete:
            return "Complete"
        }
    }
    
    var description: String {
        switch self {
        case .welcome:
            return "Let's get to know you better"
        case .personalInfo:
            return "Tell us about yourself"
        case .education:
            return "Your educational background"
        case .lifePlans:
            return "What are your life goals?"
        case .subscription:
            return "Choose your plan"
        case .complete:
            return "You're all set!"
        }
    }
}

// MARK: - Onboarding State
struct OnboardingState: Codable {
    var currentStep: OnboardingStep
    var isComplete: Bool
    var profile: UserResearchProfile
    
    init(currentStep: OnboardingStep = .welcome, isComplete: Bool = false) {
        self.currentStep = currentStep
        self.isComplete = isComplete
        self.profile = UserResearchProfile()
    }
}

// MARK: - User Profile
struct UserResearchProfile: Codable, Identifiable, Sendable {
    let id: UUID
    var userId: UUID
    var firstName: String?
    var lastName: String?
    var gender: Gender?
    var age: Int?
    var education: Education?
    var lifePlans: [String]
    var completedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case gender
        case age
        case education
        case lifePlans = "life_plans"
        case completedAt = "completed_at"
    }
} 