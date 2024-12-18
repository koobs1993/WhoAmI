import SwiftUI
import Supabase

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    
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
            .navigationTitle("Onboarding")
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
        }
        .padding()
    }
}

struct PersonalInfoStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("First Name", text: $viewModel.firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Last Name", text: $viewModel.lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Picker("Gender", selection: $viewModel.gender) {
                Text("Select Gender").tag(Optional<Gender>.none)
                ForEach(Gender.allCases, id: \.self) { gender in
                    Text(gender.rawValue.capitalized).tag(Optional(gender))
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Picker("Role", selection: $viewModel.role) {
                ForEach(UserRole.allCases, id: \.self) { role in
                    Text(role.rawValue.capitalized).tag(role)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
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
        }
        .padding()
    }
}

struct EducationStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Picker("Education", selection: $viewModel.education) {
                Text("Select Education").tag(Optional<WhoAmI.Education>.none)
                ForEach(WhoAmI.Education.allCases, id: \.self) { education in
                    Text(education.rawValue.capitalized).tag(Optional(education))
                }
            }
            .pickerStyle(MenuPickerStyle())
            
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
        }
        .padding()
    }
}

struct LifePlansStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("What are your life plans?", text: $viewModel.lifePlans)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
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
        }
        .padding()
    }
}

struct FinishStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Almost Done!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Thank you for providing your information.")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button {
                Task {
                    try? await viewModel.createProfile()
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
        }
        .padding()
    }
}

#Preview {
    OnboardingView(supabase: .init(supabaseURL: URL(string: "")!, supabaseKey: ""))
} 