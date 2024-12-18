import Foundation

// MARK: - Course Models
public struct Course: Identifiable, Codable {
    public let id: Int
    public let title: String
    public let description: String
    public let imageUrl: String?
    public let estimatedDuration: Int?
    public var lessons: [Lesson]?
    public let createdAt: Date
    public let updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageUrl = "image_url"
        case estimatedDuration = "estimated_duration"
        case lessons
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct Lesson: Identifiable, Codable {
    public let id: Int
    public let courseId: Int
    public let title: String
    public let content: String
    public let order: Int
    public var status: LessonStatus
    public let createdAt: Date
    public let updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case courseId = "course_id"
        case title
        case content
        case order
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct CourseQuestion: Codable, Identifiable, QuestionType {
    public let id: UUID
    public let courseId: Int
    public let lessonId: Int
    public let questionText: String
    public let questionType: QuestionResponseType
    public let options: [QuestionOption]?
    public let isRequired: Bool
    public let order: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public var uuid: UUID { id }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case courseId = "course_id"
        case lessonId = "lesson_id"
        case questionText = "question_text"
        case questionType = "question_type"
        case options
        case isRequired = "is_required"
        case order
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct CourseResponse: Codable, Identifiable {
    public let id: Int
    public let questionId: Int
    public let userId: UUID
    public let response: String
    public let createdAt: Date
    public let updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id = "response_id"
        case questionId = "question_id"
        case userId = "user_id"
        case response
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct UserCourse: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let courseId: UUID
    public let progress: CourseProgress
    public let startedAt: Date
    public let completedAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case courseId = "course_id"
        case progress
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}