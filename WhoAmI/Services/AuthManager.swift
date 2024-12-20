import Foundation
import Supabase
import Auth
import GoTrue

@MainActor
class AuthManager: ObservableObject {
    let supabase: SupabaseClient
    
    @Published var isAuthenticated = false
    @Published var currentUser: UserProfile?
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
    
    private func withRetry<T>(maxAttempts: Int = 3, operation: () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                if attempt < maxAttempts {
                    // Exponential backoff: wait longer between each retry
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt)) * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? AuthModels.AuthError.unknown
    }
    
    func signUp(data: AuthModels.BasicSignUpData) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await withRetry {
                try await supabase.auth.signUp(
                    email: data.email,
                    password: data.password,
                    data: nil
                )
            }
            
            if let user = response.session?.user,
               let userId = UUID(uuidString: user.id) {
                self.currentUser = UserProfile(
                    id: userId,
                    firstName: user.userMetadata["first_name"] as? String ?? "",
                    lastName: user.userMetadata["last_name"] as? String ?? "",
                    email: user.email ?? "",
                    avatarUrl: nil,
                    bio: nil,
                    settings: nil,
                    stats: nil,
                    subscription: nil,
                    devices: nil,
                    createdAt: user.createdAt ?? Date(),
                    updatedAt: user.updatedAt ?? Date()
                )
                self.isAuthenticated = true
            } else {
                throw AuthModels.AuthError.signUpFailed("Failed to create user account")
            }
            
        } catch let error as AuthModels.AuthError {
            throw error
        } catch let error as URLError where error.code == .timedOut {
            throw AuthModels.AuthError.signUpFailed("Request timed out. Please check your internet connection and try again.")
        } catch {
            throw AuthModels.AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    private func checkSession() async {
        do {
            if let session = try await supabase.auth.session,
               let userId = UUID(uuidString: session.user.id) {
                self.currentUser = UserProfile(
                    id: userId,
                    firstName: session.user.userMetadata["first_name"] as? String ?? "",
                    lastName: session.user.userMetadata["last_name"] as? String ?? "",
                    email: session.user.email ?? "",
                    avatarUrl: nil,
                    bio: nil,
                    settings: nil,
                    stats: nil,
                    subscription: nil,
                    devices: nil,
                    createdAt: session.user.createdAt ?? Date(),
                    updatedAt: session.user.updatedAt ?? Date()
                )
                self.isAuthenticated = true
            } else {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        } catch {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
}
