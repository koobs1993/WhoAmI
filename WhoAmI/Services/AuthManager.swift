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
    }
    
    func signUp(data: AuthModels.SignUpData) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let authResponse = try await supabase.auth.signUp(
                email: data.email,
                password: data.password
            )
            
            if authResponse.user == nil {
                throw AuthModels.AuthError.signUpFailed("Failed to get user data")
            }
            
            try await sendVerificationEmail(email: data.email)
            
        } catch let error as AuthModels.AuthError {
            throw error
        } catch {
            throw AuthModels.AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let authResponse = try await supabase.auth.signIn(
            email: email,
            password: password
        )
        
        self.currentUser = authResponse.user
        self.isAuthenticated = true
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
        self.currentUser = nil
        self.isAuthenticated = false
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
    
    private func sendVerificationEmail(email: String) async throws {
        try await supabase.auth.signUp(
            email: email,
            password: UUID().uuidString // Temporary password that will be reset
        )
    }
    
    func resetPassword(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
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
} 