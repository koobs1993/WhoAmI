import Foundation

public protocol QuestionType {
    var id: Int { get }
    var questionText: String { get }
    var questionType: QuestionResponseType { get }
    var isRequired: Bool { get }
    var options: [QuestionOption]? { get }
}

public enum QuestionResponseType: String, Codable {
    case text
    case shortAnswer = "short_answer"
    case longAnswer = "long_answer"
    case multipleChoice = "multiple_choice"
    case singleChoice = "single_choice"
    case date
    case number
}

public struct QuestionOption: Codable, Identifiable {
    public let id: Int
    public let questionId: Int
    public let text: String
    public let value: String
    public let order: Int
    
    public init(id: Int, questionId: Int, text: String, value: String, order: Int) {
        self.id = id
        self.questionId = questionId
        self.text = text
        self.value = value
        self.order = order
    }
}
