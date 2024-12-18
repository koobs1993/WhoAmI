import Foundation

public struct OnboardingQuestion: Codable, Identifiable {
    public let id: UUID
    public let question: String
    public let options: [String]?
    public let type: QuestionType
    public let required: Bool
    public let order: Int
    
    public enum QuestionType: String, Codable {
        case text
        case multipleChoice
        case singleChoice
        case date
        case number
    }
    
    public init(id: UUID = UUID(), question: String, options: [String]? = nil, type: QuestionType, required: Bool = true, order: Int) {
        self.id = id
        self.question = question
        self.options = options
        self.type = type
        self.required = required
        self.order = order
    }
}
