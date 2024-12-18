import Foundation

enum AuthError: LocalizedError {
    case notAuthenticated
    case invalidCredentials
    case sessionExpired
    case networkError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated"
        case .invalidCredentials:
            return "Invalid credentials"
        case .sessionExpired:
            return "Session has expired"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 