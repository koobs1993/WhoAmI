import SwiftUI

struct ReviewPromptView: View {
    @ObservedObject var manager: ReviewPromptManager
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
                                .onTapGesture {
                                    rating = star
                                }
                        }
                    }
                }
                
                Section(header: Text("Additional Feedback")) {
                    TextEditor(text: $feedback)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Submit") {
                        Task {
                            try? await manager.saveReviewHistory()
                            isPresented = false
                        }
                    }
                    .disabled(rating == nil)
                }
            }
            .navigationTitle("Leave a Review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    ReviewPromptView(
        manager: ReviewPromptManager(supabase: Config.supabaseClient),
        isPresented: .constant(true)
    )
} 