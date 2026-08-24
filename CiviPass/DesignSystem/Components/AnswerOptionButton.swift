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
                        .transition(.scale.combined(with: .opacity))
                } else if isRevealed && isSelected {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(CPColor.danger)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(CPSpacing.sm)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: isRevealed ? 1.5 : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isRevealed)
        .animation(.easeInOut(duration: 0.2), value: isRevealed)
    }

    private var backgroundColor: Color {
        guard isRevealed else { return CPColor.secondaryBackground }
        if isCorrectAnswer { return CPColor.success.opacity(0.15) }
        if isSelected { return CPColor.danger.opacity(0.15) }
        return CPColor.secondaryBackground
    }

    private var borderColor: Color {
        guard isRevealed else { return .clear }
        if isCorrectAnswer { return CPColor.success }
        if isSelected { return CPColor.danger }
        return .clear
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
