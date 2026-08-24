import SwiftUI

struct DifficultyBadge: View {
    let difficulty: QuestionDifficulty

    var body: some View {
        Text(difficulty.rawValue.capitalized)
            .font(CPTypography.footnote.bold())
            .padding(.horizontal, CPSpacing.sm)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var color: Color {
        switch difficulty {
        case .easy: return CPColor.success
        case .medium: return CPColor.warning
        case .hard: return CPColor.danger
        }
    }
}

#Preview {
    HStack {
        DifficultyBadge(difficulty: .easy)
        DifficultyBadge(difficulty: .medium)
        DifficultyBadge(difficulty: .hard)
    }
    .padding()
}
