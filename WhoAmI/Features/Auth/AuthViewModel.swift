import SwiftUI
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    private let authManager: AuthManager
    
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    init(supabase: SupabaseClient) {
        self.authManager = AuthManager(supabase: supabase)
        Task {
            await checkSession()
        }
    }
    
    private func checkSession() async {
        await authManager.checkSession()
        isAuthenticated = authManager.isAuthenticated
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
            try await authManager.signIn(email: email, password: password)
            isAuthenticated = true
            clearFields()
        } catch let error as URLError where error.code == .timedOut {
            errorMessage = "Connection timed out. Please check your internet connection and try again."
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
            try await authManager.signUp(data: .init(email: email, password: password))
            
            // Update profile with additional info
            try await authManager.updateProfile(data: .init(
                email: email,
                password: password,
                firstName: name.components(separatedBy: " ").first ?? name,
                lastName: name.components(separatedBy: " ").dropFirst().joined(separator: " "),
                gender: .notSpecified,
                role: .student
            ))
            
            isAuthenticated = true
            clearFields()
        } catch let error as URLError where error.code == .timedOut {
            errorMessage = "Connection timed out. Please check your internet connection and try again."
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
            try await authManager.resetPassword(email: email)
        } catch {
            handleError(error)
            throw error
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        do {
            try await authManager.signOut()
            isAuthenticated = false
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
        errorMessage = ""
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func handleError(_ error: Error) {
        if let authError = error as? AuthError {
            errorMessage = authError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
