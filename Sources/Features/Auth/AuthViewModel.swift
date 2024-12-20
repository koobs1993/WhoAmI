import SwiftUI
import Supabase
import GoTrue
import AuthenticationServices
import UIKit

@MainActor
class AuthViewModel: ObservableObject {
    private let supabase: SupabaseClient
    
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var phoneNumber = ""
    @Published var otpCode = ""
    @Published var isMFAEnabled = false
    @Published var mfaSecret = ""
    
    // Session refresh timer
    private var refreshTimer: Timer?
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
        Task {
            await checkSession()
            setupSessionRefresh()
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    private func checkSession() async {
        do {
            let session = try await supabase.auth.session
            isAuthenticated = true
            // Check if MFA is enabled for the user
            let factors = try await supabase.auth.mfa.listFactors()
            isMFAEnabled = !factors.all.isEmpty
        } catch {
            isAuthenticated = false
        }
    }
    
    private func setupSessionRefresh() {
        refreshTimer?.invalidate()
        // Refresh session every 30 minutes
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            Task {
                await self?.refreshSession()
            }
        }
    }
    
    private func refreshSession() async {
        do {
            _ = try await supabase.auth.refreshSession()
        } catch {
            handleError(error)
        }
    }
    
    func signIn() async throws {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            _ = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            isAuthenticated = true
            clearFields()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func signUp() async throws {
        // Validate input fields
        guard !name.isEmpty else {
            errorMessage = "Please enter your name"
            return
        }
        
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter a password"
            return
        }
        
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            // Create user account
            _ = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": .string(name)]
            )
            
            isAuthenticated = true
            clearFields()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func resetPassword(email: String) async throws {
        guard !email.isEmpty else {
            throw AuthError.invalidEmail
        }
        
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
        } catch {
            handleError(error)
            throw error
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        do {
            try await supabase.auth.signOut()
            isAuthenticated = false
        } catch {
            handleError(error)
        }
        isLoading = false
    }
    
    // Social Authentication
    func signInWithProvider(_ provider: Auth.Provider) async throws {
        isLoading = true
        errorMessage = ""
        
        do {
            guard let redirectURL = URL(string: "whoami://login-callback") else {
                throw AuthError.unknown
            }
            
            let authURL = try await supabase.auth.getOAuthSignInURL(
                provider: provider,
                redirectTo: redirectURL
            )
            
            guard let url = authURL else {
                throw AuthError.unknown
            }
            
            if await UIApplication.shared.canOpenURL(url) {
                await UIApplication.shared.open(url, options: [:])
            } else {
                throw AuthError.unknown
            }
        } catch {
            handleError(error)
            throw error
        } finally {
            isLoading = false
        }
    }
    
    // Phone Authentication
    func signInWithPhone() async throws {
        guard !phoneNumber.isEmpty else {
            errorMessage = "Please enter your phone number"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            _ = try await supabase.auth.signInWithOTP(
                phone: phoneNumber
            )
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func verifyOTP() async throws {
        guard !otpCode.isEmpty else {
            errorMessage = "Please enter the verification code"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            _ = try await supabase.auth.verifyOTP(
                phone: phoneNumber,
                token: otpCode,
                type: .sms
            )
            isAuthenticated = true
            clearFields()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MFA Methods
    func enableMFA() async throws {
        isLoading = true
        errorMessage = ""
        
        do {
            let factors = try await supabase.auth.mfa.listFactors()
            if factors.all.isEmpty {
                let params = MFAEnrollParams(
                    factorType: "totp",
                    issuer: "YourApp",
                    friendlyName: "Authenticator"
                )
                let enrollResponse = try await supabase.auth.mfa.enroll(params: params)
                
                // Store the secret for QR code generation
                mfaSecret = enrollResponse.totp.secret
                UserDefaults.standard.set(enrollResponse.id, forKey: "mfa_factor_id")
                isMFAEnabled = true
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func verifyMFAChallenge(code: String) async throws {
        isLoading = true
        errorMessage = ""
        
        do {
            if let factorId = UserDefaults.standard.string(forKey: "mfa_factor_id") {
                let challengeParams = MFAChallengeParams(factorId: factorId)
                let challenge = try await supabase.auth.mfa.challenge(params: challengeParams)
                
                let verifyParams = MFAVerifyParams(
                    factorId: factorId,
                    challengeId: challenge.id,
                    code: code
                )
                try await supabase.auth.mfa.verify(params: verifyParams)
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func disableMFA() async throws {
        isLoading = true
        errorMessage = ""
        
        do {
            if let factorId = UserDefaults.standard.string(forKey: "mfa_factor_id") {
                let params = MFAUnenrollParams(factorId: factorId)
                try await supabase.auth.mfa.unenroll(params: params)
                UserDefaults.standard.removeObject(forKey: "mfa_factor_id")
                isMFAEnabled = false
                mfaSecret = ""
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func clearFields() {
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
        phoneNumber = ""
        otpCode = ""
        errorMessage = ""
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func handleError(_ error: Error) {
        if let authError = error as? AuthError {
            switch authError {
            case .invalidEmail:
                errorMessage = "Please enter a valid email address"
            case .userNotFound:
                errorMessage = "No account found with this email"
            case .wrongPassword:
                errorMessage = "Incorrect password"
            case .emailTaken:
                errorMessage = "An account with this email already exists"
            case .invalidPhone:
                errorMessage = "Please enter a valid phone number"
            case .invalidOTP:
                errorMessage = "Invalid verification code"
            case .mfaRequired:
                errorMessage = "MFA verification required"
            case .unknown:
                errorMessage = "An error occurred during authentication"
            }
        } else {
            errorMessage = error.localizedDescription
        }
    }
}

// Extended AuthError enum
enum AuthError: LocalizedError {
    case invalidEmail
    case userNotFound
    case wrongPassword
    case emailTaken
    case invalidPhone
    case invalidOTP
    case mfaRequired
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email address"
        case .userNotFound:
            return "No account found with this email"
        case .wrongPassword:
            return "Incorrect password"
        case .emailTaken:
            return "Email is already in use"
        case .invalidPhone:
            return "Invalid phone number"
        case .invalidOTP:
            return "Invalid verification code"
        case .mfaRequired:
            return "MFA verification required"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
}

// Provider enum for social auth
enum Provider: String {
    case google
    case apple
    case facebook
    case github
    case discord
    case twitter
}
