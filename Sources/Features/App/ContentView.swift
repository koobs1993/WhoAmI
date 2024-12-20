import SwiftUI
import Supabase

struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                HomeView()
            } else {
                AuthView()
            }
        }
    }
}

struct AuthView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("WhoAmI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if isSignUp {
                    TextField("Name", text: $authViewModel.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                TextField("Email", text: $authViewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $authViewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if isSignUp {
                    SecureField("Confirm Password", text: $authViewModel.confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                if authViewModel.errorMessage.isEmpty == false {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    Task {
                        do {
                            if isSignUp {
                                try await authViewModel.signUp()
                            } else {
                                try await authViewModel.signIn()
                            }
                        } catch {
                            print("Authentication error: \(error)")
                        }
                    }
                }) {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(authViewModel.isLoading)
                
                Button(action: {
                    isSignUp.toggle()
                    authViewModel.clearFields()
                }) {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                
                Divider()
                    .padding(.vertical)
                
                Text("Or continue with")
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    ForEach([Auth.Provider.google, .apple]) { provider in
                        Button(action: {
                            Task {
                                do {
                                    try await authViewModel.signInWithProvider(provider)
                                } catch {
                                    print("Social auth error: \(error)")
                                }
                            }
                        }) {
                            Image(systemName: provider == .google ? "g.circle.fill" : "apple.logo")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to WhoAmI!")
                    .font(.title)
                
                Button(action: {
                    Task {
                        await authViewModel.signOut()
                    }
                }) {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel(supabase: SupabaseClient.shared))
} 