import SwiftUI
import Supabase

struct TestDetailView: View {
    let test: PsychTest
    let supabase: SupabaseClient
    let userId: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var showingStartConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: AdaptiveLayout.standardSpacing) {
                // Header Section
                VStack(alignment: .leading, spacing: AdaptiveLayout.minimumSpacing) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 8) {
                            Label("\(test.durationMinutes) minutes", systemImage: "clock")
                            Label("\(test.questions.count) questions", systemImage: "list.bullet")
                        }
                        .font(.adaptiveSubheadline())
                        .foregroundStyle(.secondary)
                    }
                    
                    Text(test.title)
                        .font(.adaptiveTitle())
                        .fontWeight(.bold)
                    
                    Text(test.description)
                        .font(.adaptiveBody())
                        .foregroundStyle(.secondary)
                }
                
                // Benefits Section
                VStack(alignment: .leading, spacing: AdaptiveLayout.minimumSpacing) {
                    Text("What You'll Learn")
                        .font(.adaptiveTitle())
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: AdaptiveLayout.minimumSpacing) {
                        ForEach(test.benefits) { benefit in
                            HStack(alignment: .top, spacing: AdaptiveLayout.minimumSpacing) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(benefit.title)
                                        .font(.adaptiveHeadline())
                                    
                                    Text(benefit.description)
                                        .font(.adaptiveSubheadline())
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                
                // Instructions Section
                VStack(alignment: .leading, spacing: AdaptiveLayout.minimumSpacing) {
                    Text("Instructions")
                        .font(.adaptiveTitle())
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: AdaptiveLayout.minimumSpacing) {
                        InstructionRow(
                            icon: "clock",
                            title: "Time Limit",
                            description: "You have \(test.durationMinutes) minutes to complete the test"
                        )
                        
                        InstructionRow(
                            icon: "arrow.left",
                            title: "Navigation",
                            description: "You can go back to previous questions"
                        )
                        
                        InstructionRow(
                            icon: "checkmark.circle",
                            title: "Answers",
                            description: "Choose the best answer for each question"
                        )
                        
                        InstructionRow(
                            icon: "chart.bar",
                            title: "Results",
                            description: "You'll get detailed results after completion"
                        )
                    }
                }
                
                // Start Button
                Button {
                    showingStartConfirmation = true
                } label: {
                    Text("Start Test")
                        .font(.adaptiveHeadline())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .adaptivePadding()
                        .background(Color.blue)
                        .adaptiveCornerRadius()
                }
                .adaptivePadding(.top)
            }
            .adaptivePadding()
        }
        .navigationTitle("Test Details")
        .ifOS(.iOS) { view in
            view.navigationBarTitleDisplayMode(.inline)
        }
        .alert("Ready to Begin?", isPresented: $showingStartConfirmation) {
            Button("Cancel", role: .cancel) { }
            
            NavigationLink("Start") {
                TestSessionView(
                    supabase: supabase,
                    userId: userId,
                    test: test
                )
            }
        } message: {
            Text("Make sure you have \(test.durationMinutes) minutes of uninterrupted time.")
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: AdaptiveLayout.minimumSpacing) {
            Image(systemName: icon)
                .font(.adaptiveTitle())
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.adaptiveHeadline())
                
                Text(description)
                    .font(.adaptiveSubheadline())
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationView {
        TestDetailView(
            test: .preview,
            supabase: Config.supabaseClient,
            userId: UUID()
        )
    }
}
