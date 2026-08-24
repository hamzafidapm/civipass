import Testing
import SwiftData
@testable import CiviPass

struct CiviPassTests {
    @Test func appStateDefaultsToTodayTab() {
        let appState = AppState()
        #expect(appState.selectedTab == .today)
        #expect(appState.hasCompletedOnboarding == false)
    }

    @Test func studyCategoryHasThreeCases() {
        #expect(StudyCategory.allCases.count == 3)
    }

    @Test func seedingLoadsBundledQuestions() throws {
        let container = try ModelContainer(
            for: Question.self, StudyStreak.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)

        try QuestionRepository.seedIfNeeded(context: context)

        let total = try context.fetchCount(FetchDescriptor<Question>())
        #expect(total == 10)

        let government = try QuestionRepository.questions(in: .americanGovernment, context: context)
        #expect(government.count == 5)

        let history = try QuestionRepository.questions(in: .americanHistory, context: context)
        #expect(history.count == 5)

        let quizSet = try QuestionRepository.randomQuizSet(count: 4, context: context)
        #expect(quizSet.count == 4)

        // Seeding again must not duplicate — it's a no-op once the store is non-empty.
        try QuestionRepository.seedIfNeeded(context: context)
        let totalAfterRerun = try context.fetchCount(FetchDescriptor<Question>())
        #expect(totalAfterRerun == 10)
    }

    @Test func quizScoringCountsCorrectAnswers() {
        let q1 = Question(category: .americanGovernment, questionText: "Q1", options: ["A", "B"], correctAnswerIndex: 0, difficulty: .easy)
        let q2 = Question(category: .americanGovernment, questionText: "Q2", options: ["A", "B"], correctAnswerIndex: 1, difficulty: .easy)
        let q3 = Question(category: .americanHistory, questionText: "Q3", options: ["A", "B", "C"], correctAnswerIndex: 2, difficulty: .medium)

        let viewModel = QuizViewModel()
        viewModel.configure(with: [q1, q2, q3])
        #expect(viewModel.isFinished == false)

        viewModel.selectAnswer(0) // correct for q1
        #expect(viewModel.correctCount == 1)
        viewModel.advance()

        viewModel.selectAnswer(0) // incorrect for q2 (correct index is 1)
        #expect(viewModel.correctCount == 1)
        viewModel.advance()

        #expect(viewModel.isFinished == false)
        viewModel.selectAnswer(2) // correct for q3
        viewModel.advance()

        #expect(viewModel.isFinished == true)
        #expect(viewModel.correctCount == 2)
        #expect(viewModel.scorePercentage == 67)
    }
}
