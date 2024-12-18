import SwiftUI
import Supabase
import AppKit

struct TestDetailView: View {
    let test: PsychTest

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    infoCard
                    startButton
                }
                .padding()
            }
        }
        .navigationTitle(test.title)
    }

    private var infoCard: some View {
        InfoCardContainer(test: test)
    }

    private var startButton: some View {
        Button(action: {}) {
            HStack {
                Text("Start Test")
                    .font(.headline)
                Spacer()
                Image(systemName: "arrow.right")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .frame(height: 50)
    }
}

private struct InfoCardContainer: View {
    let test: PsychTest

    var body: some View {
        CardBackground {
            ContentView(test: test)
        }
    }

    private struct ContentView: View {
        let test: PsychTest

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                InfoRow(
                    icon: "clock",
                    title: "Duration",
                    description: "\(test.durationMinutes) minutes"
                )

                InfoRow(
                    icon: "info.circle",
                    title: "Description",
                    description: test.shortDescription
                )
                
                if !test.benefits.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Benefits")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ForEach(test.benefits) { benefit in
                            Text("• \(benefit.title)")
                                .font(.body)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
}

struct CardBackground<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.windowBackgroundColor))
            )
    }
}

private struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(description)
                    .font(.body)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TestDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestDetailView(test: PsychTest(
                title: "Sample Test",
                description: "A sample test description",
                shortDescription: "Short description",
                category: .personality,
                imageUrl: nil,
                duration: 1800, // 30 minutes in seconds
                durationMinutes: 30,
                isActive: true,
                questions: [
                    PsychTest.TestQuestion(
                        questionId: 1,
                        question: "Sample Question",
                        options: [
                            QuestionOption(text: "Option 1", value: 1),
                            QuestionOption(text: "Option 2", value: 2)
                        ]
                    )
                ],
                benefits: [
                    TestBenefit(id: UUID(), title: "Benefit 1", description: "Description 1"),
                    TestBenefit(id: UUID(), title: "Benefit 2", description: "Description 2")
                ]
            ))
        }
    }
}
