import SwiftUI
import Supabase

@available(macOS 12.0, *)
struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var isSignUp = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                #if os(iOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                #endif
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            if isSignUp {
                // Sign Up View
                Button(action: {
                    Task {
                        do {
                            try await viewModel.signUp()
                        } catch {
                            // Error is already handled in AuthViewModel
                        }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
                
                Button("Already have an account? Sign In") {
                    isSignUp = false
                    viewModel.errorMessage = ""
                }
                .foregroundColor(.accentColor)
                
            } else {
                // Sign In View
                Button(action: {
                    Task {
                        do {
                            try await viewModel.signIn()
                        } catch {
                            // Error is already handled in AuthViewModel
                        }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
                
                Button("Forgot Password?") {
                    Task {
                        await viewModel.sendPasswordReset(email: viewModel.email)
                    }
                }
                .foregroundColor(.accentColor)
                .disabled(viewModel.isLoading)
                
                Button("Need an account? Sign Up") {
                    isSignUp = true
                    viewModel.errorMessage = ""
                }
                .foregroundColor(.accentColor)
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#if DEBUG
@available(macOS 12.0, *)
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: AuthViewModel(supabase: Config.supabaseClient))
    }
}
#endif
