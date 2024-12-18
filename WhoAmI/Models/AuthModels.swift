import Foundation

enum AuthModels {
    enum AuthError: LocalizedError {
        case signUpFailed(String)
        case signInFailed(String)
        case signOutFailed(String)
        case verificationFailed(String)
        case emailNotVerified
        case userNotFound
        case invalidCredentials
        case networkError(Error)
        
        var errorDescription: String? {
            switch self {
            case .signUpFailed(let message):
                return "Failed to sign up: \(message)"
            case .signInFailed(let message):
                return "Failed to sign in: \(message)"
            case .signOutFailed(let message):
                return "Failed to sign out: \(message)"
            case .verificationFailed(let message):
                return "Failed to verify email: \(message)"
            case .emailNotVerified:
                return "Please verify your email address before signing in"
            case .userNotFound:
                return "User not found"
            case .invalidCredentials:
                return "Invalid email or password"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    // Basic signup data for initial registration
    struct BasicSignUpData {
        let email: String
        let password: String
    }
    
    // Full signup data for profile completion
    struct SignUpData: Codable {
        let email: String
        let password: String
        let firstName: String
        let lastName: String
        let gender: Gender
        let role: UserRole
        
        enum CodingKeys: String, CodingKey {
            case email
            case password
            case firstName = "first_name"
            case lastName = "last_name"
            case gender
            case role
        }
    }
    
    struct SignInData {
        let email: String
        let password: String
    }
}
