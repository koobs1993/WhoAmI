import Foundation

// MARK: - Onboarding Step
public enum OnboardingStep: String, Codable, CaseIterable {
    case welcome
    case personalInfo
    case education
    case lifePlans
    case finish
    
    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .personalInfo: return "Personal Information"
        case .education: return "Education"
        case .lifePlans: return "Life Plans"
        case .finish: return "Complete"
        }
    }
    
    var description: String {
        switch self {
        case .welcome: return "Let's get to know you better"
        case .personalInfo: return "Tell us about yourself"
        case .education: return "Your educational background"
        case .lifePlans: return "What are your life goals?"
        case .finish: return "You're all set!"
        }
    }
}

// MARK: - User Research Profile
public struct UserResearchProfile: Codable, Identifiable, Sendable {
    public let id: UUID
    public var userId: UUID
    public var profile: UserProfile
    public var ageRange: AgeRange?
    public var education: Education?
    public var expectation: Expectation?
    public var primaryMotivator: PrimaryMotivator?
    public var activityFrequency: ActivityFrequency?
    public var lifePlans: [String]
    public var completedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case profile
        case ageRange = "age_range"
        case education
        case expectation
        case primaryMotivator = "primary_motivator"
        case activityFrequency = "activity_frequency"
        case lifePlans = "life_plans"
        case completedAt = "completed_at"
    }
}

// MARK: - Enums
public enum AgeRange: String, Codable, CaseIterable, Sendable {
    case age18to24 = "18-24"
    case age25to34 = "25-34"
    case age35to44 = "35-44"
    case age45to54 = "45-54"
    case age55to64 = "55-64"
    case age65Plus = "65+"
    
    public var displayText: String { rawValue }
}

public enum ResearchSituation: String, Codable, CaseIterable {
    case veryPositive = "Very Positive"
    case ratherPositive = "Rather Positive"
    case neutral = "Neutral"
    case ratherNegative = "Rather Negative"
    case veryNegative = "Very Negative"
    
    public var displayText: String { rawValue }
}

public enum Expectation: String, Codable, CaseIterable, Sendable {
    case personalGrowth = "Personal Growth"
    case careerAdvancement = "Career Advancement"
    case selfDiscovery = "Self Discovery"
    case skillDevelopment = "Skill Development"
    case other = "Other"
    
    public var displayText: String { rawValue }
}

public enum PrimaryMotivator: String, Codable, CaseIterable, Sendable {
    case curiosity = "Curiosity"
    case achievement = "Achievement"
    case learning = "Learning"
    case improvement = "Improvement"
    case purpose = "Purpose"
    case financialReward = "Financial Reward"
    case professionalInterest = "Professional Interest"
    case creativeFullfillment = "Creative Fulfillment"
    case socialRecognition = "Social Recognition"
    case internalNeed = "Internal Need"
    
    public var displayText: String { rawValue }
}

public enum ActivityFrequency: String, Codable, CaseIterable, Sendable {
    case everyDay = "Every Day"
    case severalTimesAWeek = "Several Times a Week"
    case onceAWeek = "Once a Week"
    case severalTimesAMonth = "Several Times a Month"
    case rarely = "Very Rarely"
    
    public var displayText: String { rawValue }
}

// MARK: - Onboarding State
public struct OnboardingState: Codable {
    public var currentStep: OnboardingStep
    public var isComplete: Bool
    public var profile: UserResearchProfile
    
    public init(currentStep: OnboardingStep = .welcome, isComplete: Bool = false, profile: UserResearchProfile) {
        self.currentStep = currentStep
        self.isComplete = isComplete
        self.profile = profile
    }
} 