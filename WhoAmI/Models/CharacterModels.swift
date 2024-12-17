import Foundation

struct Character: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let bio: String
    let imageUrl: String?
    let problems: [CharacterProblem]?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case bio
        case imageUrl = "image_url"
        case problems
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CharacterProblem: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let iconUrl: String?
    let problemId: Int
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case iconUrl = "icon_url"
        case problemId = "problem_id"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum ProblemStatus: String, Codable {
    case active = "active"
    case resolved = "resolved"
    case inProgress = "in_progress"
    case archived = "archived"
}

struct CharacterProblemRelation: Codable {
    let characterId: Int
    let problemId: UUID
    let character: Character?
    let problem: CharacterProblem?
    
    enum CodingKeys: String, CodingKey {
        case characterId = "character_id"
        case problemId = "problem_id"
        case character
        case problem
    }
} 