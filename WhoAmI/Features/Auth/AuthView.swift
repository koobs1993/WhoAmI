import SwiftUI
import Supabase

struct AuthView: View {
    @StateObject private var viewModel: AuthViewModel
    @State private var isSignUp = false
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(supabase: supabase))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            authForm
        }
        .padding()
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarTrailing) {
                Button(isSignUp ? "Sign In" : "Sign Up") {
                    isSignUp.toggle()
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button(isSignUp ? "Sign In" : "Sign Up") {
                    isSignUp.toggle()
                }
            }
            #endif
        }
    }
    
    private var authForm: some View {
        VStack(spacing: 16) {
            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.title)
                .fontWeight(.bold)
            
            if viewModel.error != nil {
                Text(viewModel.error?.localizedDescription ?? "")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.emailAddress)
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)
            
            if isSignUp {
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.newPassword)
            }
            
            Button {
                Task {
                    await viewModel.authenticate(isSignUp: isSignUp)
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            
            if !isSignUp {
                Button("Forgot Password?") {
                    Task {
                        await viewModel.resetPassword()
                    }
                }
                .font(.caption)
            }
        }
        .frame(maxWidth: 400)
    }
}

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var error: Error?
    
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    @MainActor
    func authenticate(isSignUp: Bool) async {
        guard !email.isEmpty, !password.isEmpty else { return }
        if isSignUp && password != confirmPassword {
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match"])
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            if isSignUp {
                _ = try await supabase.auth.signUp(
                    email: email,
                    password: password
                )
            } else {
                _ = try await supabase.auth.signIn(
                    email: email,
                    password: password
                )
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    @MainActor
    func resetPassword() async {
        guard !email.isEmpty else {
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please enter your email"])
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
} 