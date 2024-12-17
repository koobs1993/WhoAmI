import Foundation
import Supabase

@MainActor
class WeeklyColumnViewModel: ObservableObject {
    @Published var columns: [WeeklyColumn] = []
    @Published var selectedColumn: WeeklyColumn?
    @Published var questions: [WeeklyQuestion] = []
    @Published var progress: [Int: UserWeeklyProgress] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    
    var selectedColumnId: Int?
    let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchColumns() async {
        isLoading = true
        error = nil
        
        do {
            columns = try await service.fetchColumns()
            // Update progress for each column
            for column in columns {
                if let progress = try? await service.fetchProgress(for: column.id) {
                    self.progress[column.id] = progress
                }
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func fetchSelectedColumn() async {
        guard let columnId = selectedColumnId else { return }
        isLoading = true
        error = nil
        
        do {
            selectedColumn = columns.first { $0.id == columnId }
            questions = try await service.fetchQuestions(for: columnId)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func submitResponse(_ response: String) async {
        guard let columnId = selectedColumnId,
              currentQuestionIndex >= 0,
              currentQuestionIndex < questions.count else { return }
        
        let currentQuestion = questions[currentQuestionIndex]
        
        do {
            try await service.saveResponse(
                userId: userId,
                questionId: currentQuestion.id,
                response: response
            )
            
            if currentQuestionIndex == questions.count - 1 {
                try await service.saveProgress(
                    userId: userId,
                    columnId: columnId,
                    lastQuestionId: currentQuestion.id,
                    completed: true
                )
            } else {
                currentQuestionIndex += 1
                try await service.saveProgress(
                    userId: userId,
                    columnId: columnId,
                    lastQuestionId: currentQuestion.id,
                    completed: false
                )
            }
        } catch {
            self.error = error
        }
    }
} 