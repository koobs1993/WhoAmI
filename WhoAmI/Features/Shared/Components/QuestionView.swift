import SwiftUI

protocol QuestionType {
    var uuid: UUID { get }
    var questionText: String { get }
    var questionType: QuestionResponseType { get }
    var options: [QuestionOption]? { get }
    var isRequired: Bool { get }
}

struct SharedQuestionView<T: QuestionType>: View {
    let question: T
    @Binding var response: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.questionText)
                .font(.headline)
            
            if question.isRequired {
                Text("*Required")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            switch question.questionType {
            case .multipleChoice:
                if let options = question.options {
                    ForEach(options) { option in
                        Button(action: {
                            response = option.value
                        }) {
                            HStack {
                                Image(systemName: response == option.value ? "checkmark.circle.fill" : "circle")
                                Text(option.text)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            case .shortAnswer:
                TextField("Enter your answer", text: $response)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            case .longAnswer:
                TextEditor(text: $response)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            case .trueFalse:
                Picker("Select answer", selection: $response) {
                    Text("True").tag("true")
                    Text("False").tag("false")
                }
                .pickerStyle(SegmentedPickerStyle())
            case .rating:
                HStack {
                    ForEach(1...5, id: \.self) { rating in
                        Button(action: {
                            response = String(rating)
                        }) {
                            Image(systemName: Int(response) ?? 0 >= rating ? "star.fill" : "star")
                        }
                        .foregroundColor(.yellow)
                    }
                }
            }
        }
        .padding()
    }
}

// Preview provider
struct SharedQuestionView_Previews: PreviewProvider {
    struct PreviewQuestion: QuestionType {
        let uuid = UUID()
        let questionText = "Sample Question"
        let questionType = QuestionResponseType.multipleChoice
        let options: [QuestionOption]? = [
            QuestionOption(id: 1, questionId: 1, text: "Option 1", value: "1", order: 1),
            QuestionOption(id: 2, questionId: 1, text: "Option 2", value: "2", order: 2)
        ]
        let isRequired = true
    }
    
    static var previews: some View {
        SharedQuestionView(
            question: PreviewQuestion(),
            response: .constant("")
        )
    }
} 