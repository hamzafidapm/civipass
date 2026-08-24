import SwiftUI

/// A single tappable answer option, showing correct/incorrect state once revealed.
struct AnswerOptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrectAnswer: Bool
    let isRevealed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(CPTypography.body)
                    .multilineTextAlignment(.leading)
                Spacer()
                if isRevealed && isCorrectAnswer {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(CPColor.success)
                } else if isRevealed && isSelected {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(CPColor.danger)
                }
            }
            .padding(CPSpacing.sm)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isRevealed)
    }

    private var backgroundColor: Color {
        guard isRevealed else { return CPColor.secondaryBackground }
        if isCorrectAnswer { return CPColor.success.opacity(0.15) }
        if isSelected { return CPColor.danger.opacity(0.15) }
        return CPColor.secondaryBackground
    }
}

#Preview {
    VStack(spacing: CPSpacing.sm) {
        AnswerOptionButton(text: "The Constitution", isSelected: true, isCorrectAnswer: true, isRevealed: true) {}
        AnswerOptionButton(text: "Federal law", isSelected: false, isCorrectAnswer: false, isRevealed: true) {}
        AnswerOptionButton(text: "Not yet answered", isSelected: false, isCorrectAnswer: false, isRevealed: false) {}
    }
    .padding()
}
