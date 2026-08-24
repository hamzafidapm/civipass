import Testing
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
}
