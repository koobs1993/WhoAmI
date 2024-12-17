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
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.currentStep != .welcome {
                        Button("Back") {
                            viewModel.previousStep()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.currentStep != .finish {
                        Button("Next") {
                            viewModel.nextStep()
                        }
                    }
                }
            })
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

// MARK: - Extensions
extension AgeRange {
    var displayText: String {
        switch self {
        case .age18to24: return "18-24"
        case .age25to34: return "25-34"
        case .age35to44: return "35-44"
        case .age45to54: return "45-54"
        case .age55to64: return "55-64"
        case .age65Plus: return "65+"
        }
    }
}

extension ResearchSituation {
    var displayText: String {
        switch self {
        case .veryPositive: return "Very Positive"
        case .ratherPositive: return "Rather Positive"
        case .neutral: return "Neutral"
        case .ratherNegative: return "Rather Negative"
        case .veryNegative: return "Very Negative"
        }
    }
}

extension Expectation {
    var displayText: String {
        switch self {
        case .personalGrowth: return "Personal Growth"
        case .professionalDevelopment: return "Professional Development"
        case .financialWellbeing: return "Financial Wellbeing"
        case .socialRecognition: return "Social Recognition"
        case .selfRealization: return "Self Realization"
        }
    }
}

extension PrimaryMotivator {
    var displayText: String {
        switch self {
        case .financialReward: return "Financial Reward"
        case .professionalInterest: return "Professional Interest"
        case .creativeFullfillment: return "Creative Fulfillment"
        case .socialRecognition: return "Social Recognition"
        case .internalNeed: return "Internal Need"
        }
    }
}

extension ActivityFrequency {
    var displayText: String {
        switch self {
        case .everyDay: return "Every Day"
        case .severalTimesWeek: return "Several Times a Week"
        case .onceWeek: return "Once a Week"
        case .severalTimesMonth: return "Several Times a Month"
        case .veryRarely: return "Very Rarely"
        }
    }
}

#Preview {
    OnboardingView(supabase: .init(supabaseURL: URL(string: "")!, supabaseKey: ""))
} 