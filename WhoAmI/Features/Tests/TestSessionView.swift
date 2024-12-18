import SwiftUI
import Supabase

struct TestSessionView: View {
    @ObservedObject private var viewModel: TestSessionViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(supabase: SupabaseClient, userId: UUID, test: PsychTest) {
        self.viewModel = TestSessionViewModel(supabase: supabase, userId: userId, test: test)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                content
            }
        }
        .navigationTitle(viewModel.test.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            if viewModel.questions.isEmpty {
                try? await viewModel.startTest()
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if let error = viewModel.error {
            ErrorView(error: error) {
                Task {
                    try? await viewModel.startTest()
                }
            }
        } else if viewModel.questions.isEmpty {
            startView
        } else if viewModel.isComplete {
            TestResultsView(
                score: Double(viewModel.answers.count),
                totalQuestions: viewModel.questions.count
            )
        } else {
            questionView
        }
    }
    
    private var startView: some View {
        VStack(spacing: 24) {
            if let imageUrl = viewModel.test.imageUrl {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                }
            }
            
            Text(viewModel.test.description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Start Test") {
                Task {
                    try? await viewModel.startTest()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var questionView: some View {
        VStack {
            ProgressView(value: viewModel.progress)
                .padding()
            
            if let question = viewModel.questions[safe: viewModel.currentQuestionIndex] {
                QuestionView(
                    question: question,
                    response: Binding(
                        get: { viewModel.answers[question.id.uuidString] ?? "" },
                        set: { viewModel.submitAnswer($0) }
                    )
                )
            }
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
