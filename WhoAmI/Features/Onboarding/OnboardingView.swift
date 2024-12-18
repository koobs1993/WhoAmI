import SwiftUI
import Supabase

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(supabase: supabase))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    switch viewModel.currentStep {
                    case .welcome:
                        WelcomeStepView(viewModel: viewModel)
                    case .personalInfo:
                        PersonalInfoStepView(viewModel: viewModel)
                    case .education:
                        EducationStepView(viewModel: viewModel)
                    case .lifePlans:
                        LifePlansStepView(viewModel: viewModel)
                    case .finish:
                        FinishStepView(viewModel: viewModel)
                    }
                }
                .padding()
            }
            .navigationTitle("Welcome")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: {
                    #if os(macOS)
                    return .automatic
                    #else
                    return .navigationBarLeading
                    #endif
                }()) {
                    if viewModel.currentStep != .welcome {
                        Button("Back") {
                            viewModel.previousStep()
                        }
                    }
                }
                
                ToolbarItem(placement: {
                    #if os(macOS)
                    return .automatic
                    #else
                    return .navigationBarTrailing
                    #endif
                }()) {
                    if viewModel.currentStep != .finish {
                        Button("Next") {
                            viewModel.nextStep()
                        }
                        .disabled(!viewModel.canProceed)
                    }
                }
            }
        }
    }
}

struct EmailField: View {
    @Binding var email: String
    
    var body: some View {
        TextField("Email", text: $email)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            #if os(iOS)
            .keyboardType(.emailAddress)
            .textContentType(.username)
            .textInputAutocapitalization(.never)
            #endif
    }
}

struct WelcomeStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to WhoAmI")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Let's get to know you better")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button {
                viewModel.nextStep()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct PersonalInfoStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Personal Information")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                TextField("First Name", text: $viewModel.firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if os(iOS)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                    #endif
                
                TextField("Last Name", text: $viewModel.lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if os(iOS)
                    .textContentType(.familyName)
                    .textInputAutocapitalization(.words)
                    #endif
                
                EmailField(email: $viewModel.email)
            }
            .padding()
            
            Button {
                viewModel.nextStep()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct EducationStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Education")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                Picker("Education", selection: $viewModel.education) {
                    Text("Select Education").tag(Optional<Education>.none)
                    ForEach(Education.allCases, id: \.self) { education in
                        Text(education.displayText)
                            .tag(Optional(education))
                    }
                }
                .pickerStyle(.menu)
            }
            .padding()
            
            Button {
                viewModel.nextStep()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct LifePlansStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Life Plans")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                TextField("Life Plans", text: $viewModel.lifePlans)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            Button {
                viewModel.nextStep()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct FinishStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Almost Done!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Thank you for providing your information")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                Task {
                    try? await viewModel.finishOnboarding()
                }
            } label: {
                Text("Complete")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    OnboardingView(supabase: .init(supabaseURL: URL(string: "")!, supabaseKey: ""))
} 