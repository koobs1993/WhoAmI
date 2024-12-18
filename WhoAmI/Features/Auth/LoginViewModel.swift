import Foundation
import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    private let authManager: AuthManager
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 