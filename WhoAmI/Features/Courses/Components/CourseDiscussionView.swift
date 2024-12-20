import SwiftUI

struct CourseDiscussionView: View {
    let courseId: UUID
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Discussion Coming Soon")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This feature is under development")
                .foregroundStyle(.secondary)
            
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .padding()
            
            Text("Join the conversation and connect with other learners")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .navigationTitle("Discussion")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
