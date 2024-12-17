import Foundation

struct PsychTest: Codable, Identifiable {
    let id: UUID
    let testId: Int
    let title: String
    let description: String
    let estimatedDuration: TimeInterval
    let questionsCount: Int?
    let category: String
    let difficulty: String
    let imageURL: URL?
    let createdAt: Date
    let updatedAt: Date?
    let status: String?
    let userProgress: TestProgress?
    
    enum CodingKeys: String, CodingKey {
        case id
        case testId = "test_id"
        case title
        case description
        case estimatedDuration = "estimated_duration"
        case questionsCount = "questions_count"
        case category
        case difficulty
        case imageURL = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case status
        case userProgress = "user_progress"
    }
    
    var imageUrl: String? {
        imageURL?.absoluteString
    }
}

struct TestProgress: Codable {
    let id: UUID
    let userId: UUID
    let testId: UUID
    let status: String
    let completedAt: Date?
    let score: Int?
    let responses: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case testId = "test_id"
        case status
        case completedAt = "completed_at"
        case score
        case responses
    }
}
// ... existing code ... 