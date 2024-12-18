import Foundation

public struct Course: Identifiable, Codable {
    public let id: Int
    public let title: String
    public let description: String?
    public let imageUrl: String?
    public let difficulty: Int
    public let category: String
    public let estimatedDuration: Int?
    public let createdAt: Date
    public let updatedAt: Date
    public let lessons: [Lesson]?
    
    public init(
        id: Int,
        title: String,
        description: String? = nil,
        imageUrl: String? = nil,
        difficulty: Int,
        category: String,
        estimatedDuration: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lessons: [Lesson]? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.difficulty = difficulty
        self.category = category
        self.estimatedDuration = estimatedDuration
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lessons = lessons
    }
}

public enum LessonStatus: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
}

public struct Lesson: Identifiable, Codable {
    public let id: Int
    public let courseId: Int
    public let title: String
    public let description: String?
    public let content: String
    public let duration: Int?
    public let order: Int
    public var status: LessonStatus?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: Int,
        courseId: Int,
        title: String,
        description: String? = nil,
        content: String,
        duration: Int? = nil,
        order: Int,
        status: LessonStatus? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.courseId = courseId
        self.title = title
        self.description = description
        self.content = content
        self.duration = duration
        self.order = order
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
