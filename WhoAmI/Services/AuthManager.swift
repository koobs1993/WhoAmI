import Foundation
import Supabase

@MainActor
class AuthManager: ObservableObject {
    let supabase: SupabaseClient
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    
    var client: SupabaseClient {
        supabase
    }
    
    var currentUserId: UUID? {
        currentUser?.id
    }
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
        Task {
            await checkSession()
        }
    }
    
    func signUp(data: AuthModels.BasicSignUpData) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let authResponse = try await supabase.auth.signUp(
                email: data.email,
                password: data.password,
                data: ["email_confirm": false]  // Disable email confirmation
            )
            
            self.currentUser = authResponse.user
            self.isAuthenticated = true
            
        } catch let error as AuthModels.AuthError {
            throw error
        } catch {
            throw AuthModels.AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let authResponse = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            self.currentUser = authResponse.user
            self.isAuthenticated = true
            
        } catch {
            throw AuthModels.AuthError.signInFailed(error.localizedDescription)
        }
    }
    
    func signOut() async throws {
        do {
            try await supabase.auth.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            throw AuthModels.AuthError.signOutFailed(error.localizedDescription)
        }
    }
    
    func refreshSession() async {
        do {
            let session = try await supabase.auth.session
            self.currentUser = session.user
            self.isAuthenticated = self.currentUser != nil
        } catch {
            self.currentUser = nil
            self.isAuthenticated = false
            print("Failed to refresh session: \(error)")
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await supabase.auth.resetPasswordForEmail(email)
        } catch {
            throw AuthModels.AuthError.signInFailed("Failed to send password reset email")
        }
    }
    
    func updatePassword(newPassword: String) async throws {
        try await supabase.auth.update(user: UserAttributes(password: newPassword))
    }
    
    func checkSession() async {
        do {
            let session = try await supabase.auth.session
            self.currentUser = session.user
            self.isAuthenticated = true
        } catch {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    // Method to update user profile after basic signup
    func updateProfile(data: AuthModels.SignUpData) async throws {
        guard let userId = currentUserId else {
            throw AuthModels.AuthError.userNotFound
        }
        
        try await supabase.database.from("profiles")
            .upsert([
                "id": userId.uuidString,
                "first_name": data.firstName,
                "last_name": data.lastName,
                "gender": data.gender.rawValue,
                "role": data.role.rawValue,
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
    }
}
