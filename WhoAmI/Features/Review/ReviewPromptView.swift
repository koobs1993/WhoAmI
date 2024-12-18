import SwiftUI
import Supabase

struct ReviewPromptView: View {
    @StateObject var manager: ReviewPromptManager
    @Binding var isPresented: Bool
    @State private var rating: Int?
    @State private var feedback: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rate Your Experience")) {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: rating != nil && star <= rating! ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.title)
                                .onTapGesture {
                                    rating = star
                                }
                        }
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Additional Feedback (Optional)")) {
                    TextEditor(text: $feedback)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: submitReview) {
                        Text("Submit Review")
                    }
                    .disabled(rating == nil)
                    
                    Button(action: { isPresented = false }) {
                        Text("Maybe Later")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("App Review")
            .alert("Thank You!", isPresented: $manager.isLoading) {
                Button("OK") { isPresented = false }
            } message: {
                Text("Your feedback helps us improve the app.")
            }
        }
    }
    
    private func submitReview() {
        guard let rating = rating else { return }
        
        Task {
            do {
                try await manager.submitReview(rating: rating, feedback: feedback.isEmpty ? nil : feedback)
                isPresented = false
            } catch {
                print("Error submitting review: \(error)")
            }
        }
    }
}

struct ReviewPromptView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewPromptView(
            manager: ReviewPromptManager(supabase: SupabaseClient(supabaseURL: URL(string: "https://example.com")!, supabaseKey: "")),
            isPresented: .constant(true)
        )
    }
}
