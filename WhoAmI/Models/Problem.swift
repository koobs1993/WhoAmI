import Foundation

struct Problem: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let createdAt: Date
    let updatedAt: Date
    
    var shortDescription: String {
        String(description.prefix(100)) + (description.count > 100 ? "..." : "")
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 