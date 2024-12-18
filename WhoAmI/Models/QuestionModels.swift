import Foundation

public protocol QuestionType {
    var questionId: Int { get }
    var questionText: String { get }
    var questionType: QuestionResponseType { get }
    var isRequired: Bool { get }
    var options: [QuestionOption]? { get }
}

public enum QuestionResponseType: String, Codable, Sendable {
    case multipleChoice = "multiple_choice"
    case text = "text"
    case shortAnswer = "short_answer"
    case scale = "scale"
}

public struct QuestionOption: Codable, Identifiable, Sendable {
    public let id: UUID
    public let text: String
    public let value: Int
    
    public init(id: UUID = UUID(), text: String, value: Int) {
        self.id = id
        self.text = text
        self.value = value
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case text
        case value
    }
}

public enum TestStatus: String, Codable, Sendable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
    case abandoned = "abandoned"
}

// Preview helper
public struct PreviewQuestionType: QuestionType {
    public let questionId: Int
    public let questionText: String
    public let questionType: QuestionResponseType
    public let isRequired: Bool
    public let options: [QuestionOption]?
    
    public init(
        questionId: Int,
        questionText: String,
        questionType: QuestionResponseType = .multipleChoice,
        isRequired: Bool = true,
        options: [QuestionOption]? = nil
    ) {
        self.questionId = questionId
        self.questionText = questionText
        self.questionType = questionType
        self.isRequired = isRequired
        self.options = options
    }
}
