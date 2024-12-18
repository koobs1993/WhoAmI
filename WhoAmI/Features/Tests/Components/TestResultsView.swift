import SwiftUI

struct TestResultsView: View {
    let score: Double
    let totalQuestions: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Test Results")
                .font(.title)
                .bold()
            
            CircularProgressView(progress: score / 100)
                .frame(width: 200, height: 200)
            
            Text("\(Int(score))%")
                .font(.system(size: 48, weight: .bold))
            
            Text("\(Int(score * Double(totalQuestions) / 100))/\(totalQuestions) Questions Correct")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
            #else
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") {
                    dismiss()
                }
            }
            #endif
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}

#Preview {
    TestResultsView(score: 85, totalQuestions: 10)
} 