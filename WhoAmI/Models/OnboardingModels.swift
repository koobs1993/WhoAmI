import Foundation

public struct OnboardingStep: Identifiable, Equatable {
    public let id: Int
    public let title: String
    public let description: String
    public let image: String
    
    public init(id: Int, title: String, description: String, image: String) {
        self.id = id
        self.title = title
        self.description = description
        self.image = image
    }
}

public struct OnboardingData {
    public static let steps: [OnboardingStep] = [
        OnboardingStep(
            id: 1,
            title: "Welcome to WhoAmI",
            description: "Discover your personality through scientifically validated tests and assessments.",
            image: "onboarding-1"
        ),
        OnboardingStep(
            id: 2,
            title: "Learn and Grow",
            description: "Take courses designed to help you understand yourself and improve your relationships.",
            image: "onboarding-2"
        ),
        OnboardingStep(
            id: 3,
            title: "Track Your Progress",
            description: "Monitor your growth and development with detailed analytics and insights.",
            image: "onboarding-3"
        )
    ]
}

public struct OnboardingState {
    public let isFirstLaunch: Bool
    public let hasCompletedOnboarding: Bool
    public let profile: OnboardingProfile
    
    public init(isFirstLaunch: Bool, hasCompletedOnboarding: Bool, profile: OnboardingProfile) {
        self.isFirstLaunch = isFirstLaunch
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.profile = profile
    }
}

public enum EducationLevel: String, Codable, CaseIterable {
    case highSchool = "High School"
    case associate = "Associate's Degree"
    case bachelor = "Bachelor's Degree"
    case master = "Master's Degree"
    case doctorate = "Doctorate"
    case other = "Other"
}

public struct OnboardingProfile: Codable {
    public var id: UUID
    public var firstName: String
    public var lastName: String
    public var email: String
    public var avatarUrl: String?
    public var bio: String?
    public var educationLevel: EducationLevel?
    public var fieldOfStudy: String?
    public var goals: String?
    public var interests: String?
    
    public init(
        id: UUID = UUID(),
        firstName: String = "",
        lastName: String = "",
        email: String = "",
        avatarUrl: String? = nil,
        bio: String? = nil,
        educationLevel: EducationLevel? = nil,
        fieldOfStudy: String? = nil,
        goals: String? = nil,
        interests: String? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.educationLevel = educationLevel
        self.fieldOfStudy = fieldOfStudy
        self.goals = goals
        self.interests = interests
    }
}
