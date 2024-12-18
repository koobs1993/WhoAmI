import SwiftUI

struct SharedQuestionView<T: QuestionType>: View {
    let question: T
    @Binding var response: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.questionText)
                .font(.headline)
            
            switch question.questionType {
            case .text, .shortAnswer:
                TextField("Your answer", text: $response)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
            case .multipleChoice:
                if let options = question.options {
                    ForEach(options) { option in
                        Button(action: {
                            response = String(option.value)
                        }) {
                            HStack {
                                Text(option.text)
                                Spacer()
                                if response == String(option.value) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(response == String(option.value) ? Color.blue.opacity(0.1) : Color(.windowBackgroundColor))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(response == String(option.value) ? Color.blue : Color.gray.opacity(0.3))
                        )
                    }
                }
                
            case .scale:
                HStack {
                    ForEach(1...5, id: \.self) { value in
                        Button(action: {
                            response = String(value)
                        }) {
                            Text("\(value)")
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(response == String(value) ? Color.blue : Color(.windowBackgroundColor))
                                )
                                .foregroundColor(response == String(value) ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
    }
}

struct SharedQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SharedQuestionView(
                question: PreviewQuestionType(
                    questionId: 1,
                    questionText: "Sample Question",
                    questionType: .multipleChoice,
                    isRequired: true,
                    options: [
                        QuestionOption(text: "Option 1", value: 1),
                        QuestionOption(text: "Option 2", value: 2)
                    ]
                ),
                response: .constant("")
            )
        }
        .padding()
    }
}
