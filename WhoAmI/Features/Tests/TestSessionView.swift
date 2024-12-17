import SwiftUI

struct TestSessionView: View {
    @StateObject private var viewModel: TestSessionViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(supabase: SupabaseClient, userId: UUID, test: PsychTest) {
        _viewModel = StateObject(wrappedValue: TestSessionViewModel(supabase: supabase, userId: userId, test: test))
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel.startTest()
                    }
                }
            } else if viewModel.questions.isEmpty {
                startView
            } else if let results = viewModel.testResults {
                TestResultsView(results: results, test: viewModel.test)
            } else {
                questionView
            }
        }
        .navigationTitle(viewModel.test.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.questions.isEmpty {
                await viewModel.startTest()
            }
        }
    }
    
    private var startView: some View {
        VStack(spacing: 24) {
            if let imageUrl = viewModel.test.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
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
            
            Text(viewModel.test.description ?? "")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Start Test") {
                Task {
                    await viewModel.startTest()
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
                    question: question.questionText,
                    options: question.options?.map { $0.optionText } ?? [],
                    selectedOption: viewModel.responses[question.questionId],
                    onOptionSelected: { option in
                        Task {
                            await viewModel.submitResponse(option, forQuestion: question.questionId)
                        }
                    }
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