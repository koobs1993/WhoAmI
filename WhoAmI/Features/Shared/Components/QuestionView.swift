import SwiftUI

protocol QuestionType {
    var id: UUID { get }
    var questionText: String { get }
    var questionType: QuestionResponseType { get }
    var options: [QuestionOption]? { get }
    var isRequired: Bool { get }
}

struct QuestionView<T: QuestionType>: View {
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
                            response = option.text
                        }) {
                            HStack {
                                Image(systemName: response == option.text ? "checkmark.circle.fill" : "circle")
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

// Preview provider can be added here if needed 