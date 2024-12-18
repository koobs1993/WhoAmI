import Foundation

struct UserDevice: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let deviceToken: String
    let platform: String
    let deviceType: String
    let isActive: Bool
    let lastActive: Date
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case deviceToken = "device_token"
        case platform
        case deviceType = "device_type"
        case isActive = "is_active"
        case lastActive = "last_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 