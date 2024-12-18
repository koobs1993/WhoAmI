import Foundation

public struct PsychTest: Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let description: String
    public let shortDescription: String
    public let category: TestCategory
    public let imageUrl: URL?
    public let duration: TimeInterval
    public let durationMinutes: Int
    public let isActive: Bool
    public let questions: [TestQuestion]
    public let userProgress: TestProgress?
    public let benefits: [String]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public var estimatedDuration: Int { return durationMinutes }
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        shortDescription: String,
        category: TestCategory,
        imageUrl: URL? = nil,
        duration: TimeInterval,
        durationMinutes: Int,
        isActive: Bool = true,
        questions: [TestQuestion],
        userProgress: TestProgress? = nil,
        benefits: [String]? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.shortDescription = shortDescription
        self.category = category
        self.imageUrl = imageUrl
        self.duration = duration
        self.durationMinutes = durationMinutes
        self.isActive = isActive
        self.questions = questions
        self.userProgress = userProgress
        self.benefits = benefits
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public struct TestQuestion: Codable, Identifiable, QuestionType {
        public let id: UUID
        public let question: String
        public let options: [String]
        public let correctAnswer: Int?
        public let points: Int
        
        public var questionText: String { question }
        public var questionType: QuestionResponseType {
            if options.isEmpty {
                return .text
            } else {
                return .multipleChoice
            }
        }
        public var isRequired: Bool { true }
        public var questionOptions: [QuestionOption]? {
            options.enumerated().map { index, text in
                QuestionOption(
                    id: index + 1,
                    questionId: 0,  // Not needed for this implementation
                    text: text,
                    value: String(index),
                    order: index + 1
                )
            }
        }
        
        public init(
            id: UUID = UUID(),
            question: String,
            options: [String],
            correctAnswer: Int? = nil,
            points: Int = 1
        ) {
            self.id = id
            self.question = question
            self.options = options
            self.correctAnswer = correctAnswer
            self.points = points
        }
    }
}

public enum TestCategory: String, Codable, CaseIterable {
    case personality
    case intelligence
    case emotional
    case career
    case relationship
    case health
    
    public var displayName: String {
        switch self {
        case .personality: return "Personality"
        case .intelligence: return "Intelligence"
        case .emotional: return "Emotional"
        case .career: return "Career"
        case .relationship: return "Relationship"
        case .health: return "Health"
        }
    }
}

public struct TestProgress: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let testId: UUID
    public let status: TestStatus
    public let currentQuestionIndex: Int
    public let answers: [String: String]
    public let score: Int?
    public let lastUpdated: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        testId: UUID,
        status: TestStatus = .notStarted,
        currentQuestionIndex: Int = 0,
        answers: [String: String] = [:],
        score: Int? = nil,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.testId = testId
        self.status = status
        self.currentQuestionIndex = currentQuestionIndex
        self.answers = answers
        self.score = score
        self.lastUpdated = lastUpdated
    }
}

public enum TestStatus: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
    case abandoned = "abandoned"
}
