import SwiftUI
import Supabase

struct TestSessionView: View {
    @StateObject private var viewModel: TestSessionViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    @State private var showingConfirmQuit = false
    
    init(supabase: SupabaseClient, userId: UUID, test: PsychTest) {
        _viewModel = StateObject(wrappedValue: TestSessionViewModel(
            supabase: supabase,
            userId: userId,
            test: test
        ))
    }
    
    var progressSection: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 8)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * viewModel.progress, height: 8)
            }
            .clipShape(Capsule())
        }
        .frame(height: 8)
        .padding(.horizontal)
    }
    
    private struct OptionButton: View {
        let text: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(text)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? .blue : .secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue.opacity(0.1) : Color.secondary.opacity(0.1))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private struct QuestionView: View {
        let question: String
        let options: [QuestionOption]
        let selectedIndex: Int?
        let onSelect: (Int) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text(question)
                    .font(.title3)
                    .fontWeight(.medium)
                
                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                        OptionButton(
                            text: option.text,
                            isSelected: selectedIndex == index,
                            action: { onSelect(index) }
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    var questionContent: some View {
        Group {
            if let currentQuestion = viewModel.currentQuestion {
                if let options = currentQuestion.options {
                    QuestionView(
                        question: currentQuestion.question,
                        options: options,
                        selectedIndex: viewModel.selectedAnswerIndex,
                        onSelect: viewModel.selectAnswer
                    )
                }
            }
        }
    }
    
    var navigationButtons: some View {
        HStack {
            if viewModel.currentQuestionIndex > 0 {
                Button {
                    viewModel.previousQuestion()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
            }
            
            Spacer()
            
            if viewModel.currentQuestionIndex < viewModel.test.questions.count - 1 {
                Button {
                    viewModel.nextQuestion()
                } label: {
                    Label("Next", systemImage: "chevron.right")
                        .labelStyle(.iconOnly)
                }
                .disabled(viewModel.selectedAnswerIndex == nil)
            } else {
                Button {
                    viewModel.completeTest()
                } label: {
                    Text("Complete")
                }
                .disabled(viewModel.selectedAnswerIndex == nil)
            }
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        Group {
            if viewModel.isComplete {
                TestResultsView(
                    score: Double(viewModel.currentScore) / Double(viewModel.test.questions.count) * 100,
                    totalQuestions: viewModel.test.questions.count
                )
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        progressSection
                        questionContent
                        navigationButtons
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Quit") {
                    showingConfirmQuit = true
                }
                .foregroundStyle(.red)
            }
            
            ToolbarItem(placement: .principal) {
                Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.test.questions.count)")
                    .font(.headline)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(Int(viewModel.timeRemaining / 60)):\(String(format: "%02d", Int(viewModel.timeRemaining.truncatingRemainder(dividingBy: 60))))")
                    .monospacedDigit()
                    .foregroundStyle(viewModel.timeRemaining < 60 ? .red : .primary)
            }
        }
        .alert("Quit Test?", isPresented: $showingConfirmQuit) {
            Button("Cancel", role: .cancel) { }
            Button("Quit", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Your progress will be lost.")
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .active {
                viewModel.resumeTimer()
            } else if newValue == .inactive || newValue == .background {
                viewModel.pauseTimer()
            }
        }
    }
}

#Preview {
    NavigationView {
        TestSessionView(
            supabase: Config.supabaseClient,
            userId: UUID(),
            test: .preview
        )
    }
}
