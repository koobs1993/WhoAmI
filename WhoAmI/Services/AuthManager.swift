import Foundation
import Supabase
import SwiftUI

@MainActor
class AuthManager: BaseService, ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var error: AuthModels.AuthError?
    @Published var isVerifyingEmail = false
    @Published var isLoading = false
    
    override init(supabase: SupabaseClient = Config.supabaseClient) {
        super.init(supabase: supabase)
        Task {
            await checkSession()
        }
    }
    
    func signUp(data: SignUpData) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let authResponse = try await supabase.auth.signUp(
                email: data.email,
                password: data.password
            )
            
            guard let user = authResponse.user else {
                throw AuthModels.AuthError.signUpFailed("Failed to get user data")
            }
            
            try await sendVerificationEmail(email: data.email)
            
        } catch let error as AuthModels.AuthError {
            throw error
        } catch {
            throw AuthModels.AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    func sendVerificationEmail(email: String) async throws {
        isVerifyingEmail = true
        defer { isVerifyingEmail = false }
        
        do {
            try await supabase.auth.verifyOTP(
                email: email,
                token: "", // Token will be sent via email
                type: .signup
            )
        } catch {
            throw AuthModels.AuthError.verificationFailed(error.localizedDescription)
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
            
            guard let user = authResponse.user else {
                throw AuthModels.AuthError.signInFailed("No user returned")
            }
            
            if user.emailConfirmedAt == nil {
                throw AuthModels.AuthError.emailNotVerified
            }
            
            self.currentUser = try await fetchUserProfile(userId: user.id)
            self.isAuthenticated = true
            
        } catch let error as AuthModels.AuthError {
            throw error
        } catch {
            throw AuthModels.AuthError.signInFailed(error.localizedDescription)
        }
    }
    
    func fetchUserProfile(userId: UUID) async throws -> User {
        guard let user = try await selectOne(from: "users") as User? else {
            throw AuthModels.AuthError.userNotFound
        }
        return user
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
    
    func checkSession() async {
        do {
            if let session = try await supabase.auth.session {
                self.currentUser = try await fetchUserProfile(userId: session.user.id)
                self.isAuthenticated = true
            }
        } catch {
            self.error = .signInFailed(error.localizedDescription)
        }
    }
} 