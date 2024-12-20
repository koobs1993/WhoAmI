import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                switch viewModel.currentStep {
                case 0: // Welcome
                    welcomeView
                case 1: // Personal Info
                    personalInfoView
                case 2: // Education
                    educationView
                case 3: // Goals
                    goalsView
                case 4: // Interests
                    interestsView
                default:
                    EmptyView()
                }
                
                navigationButtons
            }
            .padding()
            .navigationTitle("Welcome to WhoAmI")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
    
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Welcome to WhoAmI")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Let's get to know you better")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("We'll ask you a few questions to personalize your experience")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
    
    private var personalInfoView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Personal Information")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("First Name", text: $viewModel.profile.firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Last Name", text: $viewModel.profile.lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Email", text: $viewModel.profile.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            TextField("Bio (Optional)", text: Binding(
                get: { viewModel.profile.bio ?? "" },
                set: { viewModel.profile.bio = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var educationView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Education")
                .font(.title2)
                .fontWeight(.bold)
            
            Picker("Education Level", selection: Binding(
                get: { viewModel.profile.educationLevel ?? nil },
                set: { viewModel.profile.educationLevel = $0 }
            )) {
                Text("Select Level").tag(Optional<EducationLevel>.none)
                ForEach(EducationLevel.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(Optional(level))
                }
            }
            .pickerStyle(.menu)
            
            TextField("Field of Study (Optional)", text: Binding(
                get: { viewModel.profile.fieldOfStudy ?? "" },
                set: { viewModel.profile.fieldOfStudy = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var goalsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Goals")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("What are your goals?", text: Binding(
                get: { viewModel.profile.goals ?? "" },
                set: { viewModel.profile.goals = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("This helps us recommend relevant courses and tests")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var interestsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Interests")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("What are your interests?", text: Binding(
                get: { viewModel.profile.interests ?? "" },
                set: { viewModel.profile.interests = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("This helps us personalize your experience")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            if viewModel.currentStep > 0 {
                Button("Back") {
                    viewModel.previousStep()
                }
            }
            
            Spacer()
            
            if viewModel.currentStep < viewModel.totalSteps - 1 {
                Button("Next") {
                    viewModel.nextStep()
                }
            } else {
                Button("Finish") {
                    Task {
                        do {
                            try await viewModel.createProfile()
                            dismiss()
                        } catch {
                            viewModel.showError = true
                            viewModel.errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
        .padding(.top)
    }
}

#Preview {
    OnboardingView(viewModel: .init(supabase: .init(supabaseURL: URL(string: "")!, supabaseKey: "")))
}
