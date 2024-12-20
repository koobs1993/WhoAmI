import Foundation

enum AuthError: LocalizedError {
    case notAuthenticated
    case invalidCredentials
    case sessionExpired
    case networkError(Error)
    case unknown
    case invalidEmail
    case userNotFound
    case wrongPassword
    case emailTaken
    case signUpFailed(String)
    case signInFailed(String)
    case signOutFailed(String)
    
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
        case .invalidEmail:
            return "Invalid email address"
        case .userNotFound:
            return "No account found with this email"
        case .wrongPassword:
            return "Incorrect password"
        case .emailTaken:
            return "Email is already in use"
        case .signUpFailed(let message):
            return "Failed to sign up: \(message)"
        case .signInFailed(let message):
            return "Failed to sign in: \(message)"
        case .signOutFailed(let message):
            return "Failed to sign out: \(message)"
        }
    }
}
