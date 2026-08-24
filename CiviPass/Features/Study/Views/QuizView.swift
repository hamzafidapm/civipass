import SwiftUI
import SwiftData

struct QuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(EntitlementManager.self) private var entitlementManager
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
                QuizSummaryView(viewModel: viewModel, onRestart: startQuiz)
            } else if let question = viewModel.currentQuestion {
                QuizQuestionView(viewModel: viewModel, question: question, isFreeTierQuiz: !entitlementManager.hasPremiumAccess)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Mock Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard !hasStarted else { return }
            hasStarted = true
            startQuiz()
        }
        .onChange(of: viewModel.isFinished) {
            guard viewModel.isFinished, !viewModel.questions.isEmpty else { return }
            saveCompletedAttempt()
        }
    }

    /// Free users only ever draw from the unlocked category — a mixed quiz would
    /// otherwise leak American History / Integrated Civics content for free.
    private func startQuiz() {
        guard entitlementManager.hasPremiumAccess else {
            let freeQuestions = (try? QuestionRepository.questions(in: AccessGate.freeCategory, context: modelContext)) ?? []
            viewModel.configure(with: Array(freeQuestions.shuffled().prefix(questionCount)))
            return
        }
        viewModel.start(context: modelContext, count: questionCount)
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
    let isFreeTierQuiz: Bool

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
                    HStack {
                        Text(viewModel.progressText)
                        if isFreeTierQuiz {
                            Text("· Free quiz: American Government")
                        }
                    }
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
                        // Option text is randomized seed content, so UI tests can't target
                        // it by label — this identifier gives them a stable hook.
                        .accessibilityIdentifier("answerOption\(index)")
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
            .environment(EntitlementManager())
    }
}
