import Foundation

struct Course: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let imageUrl: String?
    let difficulty: CourseDifficulty
    let lessons: [Lesson]
    let createdAt: Date
    let updatedAt: Date
    var userProgress: CourseProgress?
    
    var lessonCount: Int {
        lessons.count
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageUrl = "image_url"
        case difficulty
        case lessons
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userProgress = "user_progress"
    }
}

struct Lesson: Codable, Identifiable {
    let id: Int
    let courseId: Int
    let title: String
    let content: String?
    let order: Int
    var status: LessonStatus
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
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

enum CourseDifficulty: String, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
}

struct LessonResource: Codable, Identifiable {
    let id: Int
    let lessonId: Int
    let title: String
    let type: ResourceType
    let url: String
    let order: Int
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "resource_id"
        case lessonId = "lesson_id"
        case title
        case type
        case url
        case order
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum ResourceType: String, Codable {
    case pdf = "pdf"
    case video = "video"
    case audio = "audio"
    case link = "link"
    case document = "document"
}

struct UserLesson: Codable, Identifiable {
    let id: Int
    let userCourseId: Int
    let lessonId: Int
    let status: CourseStatus
    let completionDate: Date?
    let lastAccessed: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "user_lesson_id"
        case userCourseId = "user_course_id"
        case lessonId = "lesson_id"
        case status
        case completionDate = "completion_date"
        case lastAccessed = "last_accessed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserResponse: Codable, Identifiable {
    let id: Int
    let userLessonId: Int
    let questionId: Int
    let response: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "response_id"
        case userLessonId = "user_lesson_id"
        case questionId = "question_id"
        case response
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CourseQuestion: Codable, Identifiable {
    let id: UUID
    let courseId: Int
    let lessonId: Int
    let questionText: String
    let questionType: QuestionResponseType
    let options: [QuestionOption]?
    let isRequired: Bool
    let order: Int
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
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

struct CourseResponse: Codable, Identifiable {
    let id: Int
    let questionId: Int
    let userId: UUID
    let response: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "response_id"
        case questionId = "question_id"
        case userId = "user_id"
        case response
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserCourse: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let courseId: UUID
    let progress: CourseProgress
    let startedAt: Date
    let completedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case courseId = "course_id"
        case progress
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}