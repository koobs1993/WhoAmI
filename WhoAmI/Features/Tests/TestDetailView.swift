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
    static let testData = PsychTest(
        id: UUID(),
        title: "Sample Test",
        shortDescription: "This is a sample test description.",
        category: .personality,
        imageUrl: nil,
        durationMinutes: 15,
        isActive: true,
        createdAt: Date(),
        updatedAt: Date(),
        userProgress: nil,
        questions: nil,
        benefits: nil
    )
    
    static var previews: some View {
        NavigationView {
            TestDetailView(test: testData)
        }
    }
}