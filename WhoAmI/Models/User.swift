import Foundation

public enum UserRole: String, Codable {
    case user = "user"
    case admin = "admin"
    case moderator = "moderator"
}

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let firstName: String?
    let lastName: String?
    let gender: Gender?
    let phone: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date?
    let emailConfirmedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case gender
        case phone
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case emailConfirmedAt = "email_confirmed_at"
    }
} 