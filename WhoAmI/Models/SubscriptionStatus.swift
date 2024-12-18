import Foundation

enum SubscriptionStatus: String, Codable {
    case active = "active"
    case canceled = "canceled"
    case expired = "expired"
    case pending = "pending"
    case trial = "trial"
    
    var isValid: Bool {
        switch self {
        case .active, .trial:
            return true
        case .canceled, .expired, .pending:
            return false
        }
    }
} 