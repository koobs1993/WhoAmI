import Foundation

struct WeeklyColumn: Codable, Identifiable {
    let id: Int
    let title: String
    let content: String
    let featuredImageUrl: String?
    let publishDate: Date
    let sequenceNumber: Int
    var userProgress: UserWeeklyProgress?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    var questions: [WeeklyQuestion]?
    
    enum CodingKeys: String, CodingKey {
        case id = "column_id"
        case title
        case content
        case featuredImageUrl = "featured_image_url"
        case publishDate = "publish_date"
        case sequenceNumber = "sequence_number"
        case userProgress = "weeklycolumnprogress"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case questions = "weeklyquestions"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        featuredImageUrl = try container.decodeIfPresent(String.self, forKey: .featuredImageUrl)
        publishDate = try container.decode(Date.self, forKey: .publishDate)
        sequenceNumber = try container.decode(Int.self, forKey: .sequenceNumber)
        userProgress = try container.decodeIfPresent(UserWeeklyProgress.self, forKey: .userProgress)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        questions = try container.decodeIfPresent([WeeklyQuestion].self, forKey: .questions)
    }
}

struct WeeklyQuestion: Codable, Identifiable {
    let id: Int
    let columnId: Int
    let question: String
    let options: [String]?
    let correctAnswer: String?
    let explanation: String?
    let order: Int
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "question_id"
        case columnId = "column_id"
        case question
        case options
        case correctAnswer = "correct_answer"
        case explanation
        case order
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserWeeklyProgress: Codable, Identifiable {
    let id: Int
    let userId: UUID
    let columnId: Int
    let isCompleted: Bool
    let completedAt: Date?
    let score: Int?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "progress_id"
        case userId = "user_id"
        case columnId = "column_id"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
        case score
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Helper Extensions

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
} 