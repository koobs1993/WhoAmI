import SwiftUI
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let authManager: AuthManager
    
    init(supabase: SupabaseClient) {
        // Use the shared AuthManager instance from ContentView
        self.authManager = AuthManager(supabase: supabase)
    }
    
    private func validateInput() -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return false
        }
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            return false
        }
        
        // Basic email format validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            errorMessage = "Please enter a valid email address"
            return false
        }
        
        // Basic password strength validation
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        
        return true
    }
    
    func signIn() async {
        guard validateInput() else { return }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await authManager.signIn(email: email, password: password)
        } catch let error as AuthModels.AuthError {
            errorMessage = error.errorDescription ?? "Sign in failed"
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    func signUp() async {
        guard validateInput() else { return }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let signUpData = AuthModels.BasicSignUpData(
                email: email,
                password: password
            )
            
            try await authManager.signUp(data: signUpData)
        } catch let error as AuthModels.AuthError {
            errorMessage = error.errorDescription ?? "Sign up failed"
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await authManager.signOut()
        } catch {
            errorMessage = "Failed to sign out"
        }
    }
    
    func sendPasswordReset(email: String) async {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }
        
        // Validate email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await authManager.resetPassword(email: email)
            errorMessage = "Password reset email sent"
        } catch {
            errorMessage = "Failed to send password reset email"
        }
        
        isLoading = false
    }
    
    // Clear form data and error messages
    func reset() {
        email = ""
        password = ""
        errorMessage = ""
        isLoading = false
    }
}
