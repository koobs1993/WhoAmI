#if os(iOS)
import UIKit
#endif
import SwiftUI

struct SharedQuestionView<T: QuestionType>: View {
    let question: T
    @Binding var response: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.questionText)
                .font(.headline)
            
            switch question.questionType {
            case .text, .shortAnswer, .longAnswer:
                TextField("Your answer", text: $response)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if os(iOS)
                    .textInputAutocapitalization(.sentences)
                    #endif
                
            case .multipleChoice, .singleChoice:
                if let options = question.questionOptions {
                    ForEach(options) { option in
                        RadioButton(
                            title: option.text,
                            isSelected: Binding(
                                get: { response == option.value },
                                set: { if $0 { response = option.value } }
                            )
                        )
                    }
                }
                
            case .date:
                DatePicker(
                    "Select date",
                    selection: Binding(
                        get: { Date(timeIntervalSince1970: Double(response) ?? Date().timeIntervalSince1970) },
                        set: { response = String($0.timeIntervalSince1970) }
                    ),
                    displayedComponents: [.date]
                )
                
            case .number:
                TextField("Enter number", text: $response)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
            }
        }
        .padding()
    }
}

struct RadioButton: View {
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: { isSelected.toggle() }) {
            HStack {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                Text(title)
            }
        }
        .foregroundColor(.primary)
    }
}

// Preview provider
struct SharedQuestionView_Previews: PreviewProvider {
    struct PreviewQuestion: QuestionType {
        let id: Int = 1
        let questionText: String
        let questionType: QuestionResponseType
        let isRequired: Bool
        let options: [QuestionOption]?
        
        init(
            questionText: String = "Sample Question",
            questionType: QuestionResponseType = .multipleChoice,
            isRequired: Bool = true,
            options: [QuestionOption]? = [
                QuestionOption(id: 1, questionId: 1, text: "Option 1", value: "1", order: 1),
                QuestionOption(id: 2, questionId: 1, text: "Option 2", value: "2", order: 2)
            ]
        ) {
            self.questionText = questionText
            self.questionType = questionType
            self.isRequired = isRequired
            self.options = options
        }
    }
    
    static var previews: some View {
        VStack {
            SharedQuestionView(question: PreviewQuestion(), response: .constant(""))
                .previewDisplayName("Multiple Choice")
            
            SharedQuestionView(
                question: PreviewQuestion(questionType: .shortAnswer, options: nil),
                response: .constant("")
            )
            .previewDisplayName("Short Answer")
            
            SharedQuestionView(
                question: PreviewQuestion(questionType: .number, options: nil),
                response: .constant("42")
            )
            .previewDisplayName("Number")
            
            SharedQuestionView(
                question: PreviewQuestion(questionType: .date, options: nil),
                response: .constant("\(Date().timeIntervalSince1970)")
            )
            .previewDisplayName("Date")
        }
        .padding()
    }
}
