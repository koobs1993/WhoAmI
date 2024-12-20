import SwiftUI

// MARK: - Text Input Question View
private struct TextInputQuestionView: View {
    @Binding var response: String
    
    var body: some View {
        TextField("Your answer", text: $response)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

// MARK: - Multiple Choice Option Button
private struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
        .buttonStyle(.plain)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.secondary.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3))
        )
    }
}

// MARK: - Multiple Choice Option List
private struct OptionList: View {
    let options: [QuestionOption]
    let selectedValue: String
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(options) { option in
                OptionButton(
                    text: option.text,
                    isSelected: selectedValue == String(option.value)
                ) {
                    onSelect(String(option.value))
                }
            }
        }
    }
}

// MARK: - Multiple Choice Question View
private struct MultipleChoiceQuestionView: View {
    let options: [QuestionOption]
    @Binding var response: String
    
    var body: some View {
        OptionList(
            options: options,
            selectedValue: response,
            onSelect: { response = $0 }
        )
    }
}

// MARK: - Scale Question View
private struct ScaleQuestionView: View {
    @Binding var response: String
    
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { value in
                Button {
                    response = String(value)
                } label: {
                    Text("\(value)")
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(response == String(value) ? Color.blue : Color.secondary.opacity(0.1))
                        )
                        .foregroundColor(response == String(value) ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Main Question View
struct SharedQuestionView<T: QuestionType>: View {
    let question: T
    @Binding var response: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.questionText)
                .font(.headline)
            
            switch question.questionType {
            case .text, .shortAnswer:
                TextInputQuestionView(response: $response)
                
            case .multipleChoice:
                if let options = question.options {
                    MultipleChoiceQuestionView(options: options, response: $response)
                }
                
            case .scale:
                ScaleQuestionView(response: $response)
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
