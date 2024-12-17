import SwiftUI
import Supabase

struct TestDetailView: View {
    let test: PsychTest
    let supabase: SupabaseClient
    @State private var showingTest = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                if let imageUrl = test.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(height: 200)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Description
                    Text(test.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(test.description)
                        .foregroundColor(.secondary)
                    
                    // Test Info
                    TestInfoView(test: test)
                    
                    // Action Button
                    if let progress = test.userProgress {
                        switch progress.status {
                        case "completed":
                            Button {
                                showingTest = true
                            } label: {
                                Label("View Results", systemImage: "chart.bar.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        case "in_progress":
                            Button {
                                showingTest = true
                            } label: {
                                Label("Continue Test", systemImage: "arrow.right.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        default:
                            Button {
                                showingTest = true
                            } label: {
                                Label("Start Test", systemImage: "play.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else {
                        Button {
                            showingTest = true
                        } label: {
                            Label("Start Test", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showingTest) {
            TestSessionView(test: test, supabase: supabase)
        }
    }
}

struct TestInfoView: View {
    let test: PsychTest
    
    var body: some View {
        VStack(spacing: 12) {
            TestInfoRowView(icon: "clock", title: "Duration", description: "\(test.estimatedDuration) minutes")
            TestInfoRowView(icon: "chart.bar", title: "Difficulty", description: test.difficulty)
            if let questionsCount = test.questionsCount {
                TestInfoRow(icon: "list.bullet", title: "Questions", description: "\(questionsCount)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemGray6))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(12)
    }
}

struct TestInfoRowView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(description)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
} 