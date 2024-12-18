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
    public let benefits: [TestBenefit]
    public let createdAt: Date
    public let updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case shortDescription = "short_description"
        case category
        case imageUrl = "image_url"
        case durationMinutes = "duration_minutes"
        case isActive = "is_active"
        case questions
        case userProgress = "testprogress"
        case benefits
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        shortDescription = try container.decode(String.self, forKey: .shortDescription)
        description = shortDescription // Using shortDescription for both
        category = try container.decode(TestCategory.self, forKey: .category)
        imageUrl = try? container.decode(URL.self, forKey: .imageUrl)
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        duration = TimeInterval(durationMinutes * 60)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        questions = try container.decode([TestQuestion].self, forKey: .questions)
        userProgress = try? container.decodeIfPresent(TestProgress.self, forKey: .userProgress)
        benefits = try container.decode([TestBenefit].self, forKey: .benefits)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(shortDescription, forKey: .shortDescription)
        try container.encode(category, forKey: .category)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(durationMinutes, forKey: .durationMinutes)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(questions, forKey: .questions)
        try container.encode(userProgress, forKey: .userProgress)
        try container.encode(benefits, forKey: .benefits)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
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
        benefits: [TestBenefit],
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
        public let questionId: Int
        public let question: String
        public let options: [QuestionOption]?
        public let correctAnswer: Int?
        public let points: Int
        public let isRequired: Bool
        public let questionType: QuestionResponseType
        
        public var questionText: String { question }
        
        private enum CodingKeys: String, CodingKey {
            case id = "uuid"
            case questionId = "id"
            case question = "text"
            case options
            case correctAnswer = "correct_answer"
            case points
            case isRequired = "required"
            case questionType = "type"
        }
        
        public init(
            id: UUID = UUID(),
            questionId: Int,
            question: String,
            options: [QuestionOption]? = nil,
            correctAnswer: Int? = nil,
            points: Int = 1,
            isRequired: Bool = true,
            questionType: QuestionResponseType = .multipleChoice
        ) {
            self.id = id
            self.questionId = questionId
            self.question = question
            self.options = options
            self.correctAnswer = correctAnswer
            self.points = points
            self.isRequired = isRequired
            self.questionType = questionType
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

public struct TestBenefit: Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let description: String
}

public struct TestProgress: Codable, Identifiable {
    public let id: UUID
    public let status: TestStatus
    public let lastUpdated: Date
    public let score: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case status
        case lastUpdated = "last_updated"
        case score
    }
    
    public init(
        id: UUID = UUID(),
        status: TestStatus,
        lastUpdated: Date = Date(),
        score: Int? = nil
    ) {
        self.id = id
        self.status = status
        self.lastUpdated = lastUpdated
        self.score = score
    }
}
