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
    }
}

private struct QuizQuestionView: View {
    let viewModel: QuizViewModel
    let question: Question

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CPSpacing.lg) {
                Text(viewModel.progressText)
                    .font(CPTypography.caption)
                    .foregroundStyle(.secondary)

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
                }

                if viewModel.selectedOptionIndex != nil {
                    Button("Next") {
                        viewModel.advance()
                    }
                    .buttonStyle(CPPrimaryButtonStyle())
                }
            }
            .padding(CPSpacing.md)
        }
    }
}

private struct QuizSummaryView: View {
    let viewModel: QuizViewModel
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: CPSpacing.lg) {
            Spacer()
            Text("Quiz Complete")
                .font(CPTypography.largeTitle)
            Text("\(viewModel.correctCount) of \(viewModel.questions.count) correct")
                .font(CPTypography.subtitle)
                .foregroundStyle(.secondary)
            Text("\(viewModel.scorePercentage)%")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(CPColor.brandPrimary)
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
