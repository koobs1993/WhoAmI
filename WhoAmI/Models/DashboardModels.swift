import Foundation

// Enums to match database types
// CourseStatus and TestStatus are now imported from SharedModels

// Weekly Column Model for Dashboard
struct DashboardWeeklyColumn: Identifiable, Codable {
    let id: Int
    let title: String
    let content: String?
    let featuredImageUrl: String?
    let sequenceNumber: Int?
    let publishDate: Date?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "column_id"
        case title
        case content
        case featuredImageUrl = "featured_image_url"
        case sequenceNumber = "sequence_number"
        case publishDate = "publish_date"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// Course Model for Dashboard
struct DashboardCourse: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    let imageUrl: String?
    let duration: Int
    let difficulty: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageUrl = "image_url"
        case duration
        case difficulty
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// Dashboard Test Model
struct DashboardTest: Identifiable, Codable {
    let id: Int
    let title: String
    let imageUrl: String?
    let durationMinutes: Int
    let totalQuestions: Int
    let description: String?
    let information: String?
    let isActive: Bool
    let deletedAt: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "test_id"
        case title
        case imageUrl = "image_url"
        case durationMinutes = "duration_minutes"
        case totalQuestions = "total_questions"
        case description
        case information
        case isActive = "is_active"
        case deletedAt = "deleted_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// User Course Progress
struct DashboardUserCourse: Identifiable, Codable {
    let id: Int
    let userId: UUID
    let courseId: Int
    let startDate: Date?
    let completionDate: Date?
    let status: CourseStatus
    let lastAccessed: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case courseId = "course_id"
        case startDate = "start_date"
        case completionDate = "completion_date"
        case status
        case lastAccessed = "last_accessed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// User Test Progress
struct DashboardUserTest: Identifiable, Codable {
    let id: Int
    let userId: UUID
    let testId: Int
    let lastQuestionId: Int?
    let startTime: Date?
    let completionTime: Date?
    let status: TestStatus
    let testResults: [String: String]?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "user_test_id"
        case userId = "user_id"
        case testId = "test_id"
        case lastQuestionId = "last_question_id"
        case startTime = "start_time"
        case completionTime = "completion_time"
        case status
        case testResults = "test_results"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CourseData: Codable {
    let course: DashboardCourse
    let progress: CourseProgress?
    
    enum CodingKeys: String, CodingKey {
        case course
        case progress
    }
}

// Use the Lesson type from CourseModels
typealias DashboardLesson = Lesson
 