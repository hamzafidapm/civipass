import Foundation
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
        #expect(total == 51)

        let government = try QuestionRepository.questions(in: .americanGovernment, context: context)
        #expect(government.count == 17)

        let history = try QuestionRepository.questions(in: .americanHistory, context: context)
        #expect(history.count == 17)

        let civics = try QuestionRepository.questions(in: .integratedCivics, context: context)
        #expect(civics.count == 17)

        let quizSet = try QuestionRepository.randomQuizSet(count: 4, context: context)
        #expect(quizSet.count == 4)

        // Seeding again must not duplicate — it's a no-op once the store is non-empty.
        try QuestionRepository.seedIfNeeded(context: context)
        let totalAfterRerun = try context.fetchCount(FetchDescriptor<Question>())
        #expect(totalAfterRerun == 51)
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

    @Test func progressStatsComputesAccuracyAndStreak() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let today = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15))!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let fourDaysAgo = calendar.date(byAdding: .day, value: -4, to: today)! // gap: shouldn't extend the streak

        let attempts = [
            QuizAttempt(date: today, totalQuestions: 10, correctCount: 8),
            QuizAttempt(date: yesterday, totalQuestions: 10, correctCount: 10),
            QuizAttempt(date: twoDaysAgo, category: .americanHistory, totalQuestions: 5, correctCount: 3),
            QuizAttempt(date: fourDaysAgo, totalQuestions: 10, correctCount: 5)
        ]

        let summary = ProgressStats.summarize(attempts, today: today, calendar: calendar)

        #expect(summary.totalQuizzes == 4)
        // 8 + 10 + 3 + 5 = 26 correct out of 10 + 10 + 5 + 10 = 35 questions
        #expect(abs(summary.overallAccuracy - (26.0 / 35.0)) < 0.0001)
        #expect(summary.currentStreakDays == 3) // today, yesterday, two days ago — then the gap breaks it
        #expect(summary.categoryBreakdown.count == 2) // Mixed (nil) and American History
    }

    @Test func currentStreakIsZeroWithoutAttemptToday() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let today = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15))!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let attemptsWithGapToday = [QuizAttempt(date: yesterday, totalQuestions: 5, correctCount: 5)]

        #expect(ProgressStats.currentStreak(attemptsWithGapToday, today: today, calendar: calendar) == 0)
        #expect(ProgressStats.currentStreak([], today: today, calendar: calendar) == 0)
    }
}
