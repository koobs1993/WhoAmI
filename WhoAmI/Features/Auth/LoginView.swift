import SwiftUI
import Supabase

@available(iOS 16.0, *)
struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var showForgotPassword = false
    @State private var showTerms = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword, name
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 32) {
                    // Logo and Welcome Text
                    VStack(spacing: 16) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        Text(isSignUp ? "Create Account" : "Welcome Back")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(isSignUp ? "Start your journey of self-discovery" : "Continue your journey of growth")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        if isSignUp {
                            TextField("", text: $viewModel.name)
                                .textFieldStyle(FloatingTextFieldStyle(title: "Full Name", icon: "person.fill"))
                                .focused($focusedField, equals: .name)
                                .textContentType(.name)
                        }
                        
                        TextField("", text: $viewModel.email)
                            .textFieldStyle(FloatingTextFieldStyle(title: "Email", icon: "envelope.fill"))
                            .focused($focusedField, equals: .email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                        
                        SecureField("", text: $viewModel.password)
                            .textFieldStyle(FloatingTextFieldStyle(title: "Password", icon: "lock.fill"))
                            .focused($focusedField, equals: .password)
                            .textContentType(isSignUp ? .newPassword : .password)
                        
                        if isSignUp {
                            SecureField("", text: $viewModel.confirmPassword)
                                .textFieldStyle(FloatingTextFieldStyle(title: "Confirm Password", icon: "lock.fill"))
                                .focused($focusedField, equals: .confirmPassword)
                                .textContentType(.newPassword)
                        }
                    }
                    
                    // Error Message
                    if !viewModel.errorMessage.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            Text(viewModel.errorMessage)
                                .foregroundStyle(.red)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button {
                            Task {
                                if isSignUp {
                                    try await viewModel.signUp()
                                } else {
                                    try await viewModel.signIn()
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(viewModel.isLoading)
                        
                        if !isSignUp {
                            Button("Forgot Password?") {
                                showForgotPassword = true
                            }
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                        }
                        
                        // Terms and Privacy
                        if isSignUp {
                            Button {
                                showTerms = true
                            } label: {
                                Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        // Toggle Sign In/Sign Up
                        HStack(spacing: 4) {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Button(isSignUp ? "Sign In" : "Sign Up") {
                                withAnimation {
                                    isSignUp.toggle()
                                    viewModel.clearFields()
                                }
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                        }
                    }
                }
                .padding()
                .frame(minHeight: geometry.size.height)
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(viewModel: viewModel)
        }
        .sheet(isPresented: $showTerms) {
            TermsView()
        }
    }
}

struct ForgotPasswordView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var message: String?
    @State private var isSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                    
                    Text("Reset Password")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter your email address and we'll send you instructions to reset your password.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                TextField("", text: $email)
                    .textFieldStyle(FloatingTextFieldStyle(title: "Email", icon: "envelope.fill"))
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                
                if let message = message {
                    HStack {
                        Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(isSuccess ? .green : .red)
                        Text(message)
                            .foregroundStyle(isSuccess ? .green : .red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isSuccess ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    Task {
                        do {
                            try await viewModel.resetPassword(email: email)
                            isSuccess = true
                            message = "Check your email for reset instructions"
                        } catch {
                            isSuccess = false
                            message = error.localizedDescription
                        }
                    }
                } label: {
                    Text("Send Reset Link")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FloatingTextFieldStyle: TextFieldStyle {
    let title: String
    let icon: String
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                configuration
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel(supabase: Config.supabaseClient))
}
