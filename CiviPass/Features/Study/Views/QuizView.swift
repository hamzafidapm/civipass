import SwiftUI
import SwiftData

struct QuizView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = QuizViewModel()
    @State private var hasStarted = false

    private let questionCount = 10

    var body: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView(
                    "Couldn't Start Quiz",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if viewModel.isFinished {
                QuizSummaryView(viewModel: viewModel) {
                    viewModel.start(context: modelContext, count: questionCount)
                }
            } else if let question = viewModel.currentQuestion {
                QuizQuestionView(viewModel: viewModel, question: question)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Mock Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard !hasStarted else { return }
            hasStarted = true
            viewModel.start(context: modelContext, count: questionCount)
        }
        .onChange(of: viewModel.isFinished) {
            guard viewModel.isFinished, !viewModel.questions.isEmpty else { return }
            saveCompletedAttempt()
        }
    }

    private func saveCompletedAttempt() {
        do {
            try QuizAttemptRepository.save(
                totalQuestions: viewModel.questions.count,
                correctCount: viewModel.correctCount,
                context: modelContext
            )
        } catch {
            print("QuizView: failed to save quiz attempt - \(error)")
        }
    }
}

private struct QuizQuestionView: View {
    let viewModel: QuizViewModel
    let question: Question

    private var progressFraction: Double {
        guard !viewModel.questions.isEmpty else { return 0 }
        return Double(viewModel.currentIndex) / Double(viewModel.questions.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CPSpacing.lg) {
                VStack(alignment: .leading, spacing: CPSpacing.xs) {
                    ProgressView(value: progressFraction)
                        .tint(CPColor.brandPrimary)
                    Text(viewModel.progressText)
                        .font(CPTypography.caption)
                        .foregroundStyle(.secondary)
                }

                Text(question.questionText)
                    .font(CPTypography.title)

                VStack(spacing: CPSpacing.sm) {
                    ForEach(question.options.indices, id: \.self) { index in
                        AnswerOptionButton(
                            text: question.options[index],
                            isSelected: viewModel.selectedOptionIndex == index,
                            isCorrectAnswer: index == question.correctAnswerIndex,
                            isRevealed: viewModel.selectedOptionIndex != nil
                        ) {
                            viewModel.selectAnswer(index)
                        }
                    }
                }

                if viewModel.selectedOptionIndex != nil, let explanation = question.explanation {
                    Text(explanation)
                        .font(CPTypography.caption)
                        .foregroundStyle(.secondary)
                        .padding(CPSpacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(CPColor.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .transition(.opacity)
                }

                if viewModel.selectedOptionIndex != nil {
                    Button("Next") {
                        viewModel.advance()
                    }
                    .buttonStyle(CPPrimaryButtonStyle())
                    .transition(.opacity)
                }
            }
            .padding(CPSpacing.md)
            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedOptionIndex)
        }
    }
}

private struct QuizSummaryView: View {
    let viewModel: QuizViewModel
    let onRestart: () -> Void

    private var scoreColor: Color {
        switch viewModel.scorePercentage {
        case 80...: return CPColor.success
        case 50..<80: return CPColor.warning
        default: return CPColor.danger
        }
    }

    private var scoreSystemImage: String {
        switch viewModel.scorePercentage {
        case 80...: return "star.fill"
        case 50..<80: return "hand.thumbsup.fill"
        default: return "arrow.clockwise"
        }
    }

    var body: some View {
        VStack(spacing: CPSpacing.lg) {
            Spacer()

            Image(systemName: scoreSystemImage)
                .font(.system(size: 44))
                .foregroundStyle(scoreColor)

            Text("Quiz Complete")
                .font(CPTypography.largeTitle)

            Text("\(viewModel.correctCount) of \(viewModel.questions.count) correct")
                .font(CPTypography.subtitle)
                .foregroundStyle(.secondary)

            Text("\(viewModel.scorePercentage)%")
                .font(CPTypography.statNumber)
                .foregroundStyle(scoreColor)

            Spacer()

            Button("Try Again", action: onRestart)
                .buttonStyle(CPPrimaryButtonStyle())
        }
        .padding(CPSpacing.lg)
    }
}

#Preview {
    NavigationStack {
        QuizView()
            .modelContainer(PersistenceController.previewModelContainer)
    }
}
