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
}
