import Foundation
import SwiftData

@Model
final class StudyStreak {
    var date: Date
    var questionsAnswered: Int
    var isDailyChallengeComplete: Bool

    init(
        date: Date,
        questionsAnswered: Int = 0,
        isDailyChallengeComplete: Bool = false
    ) {
        self.date = date
        self.questionsAnswered = questionsAnswered
        self.isDailyChallengeComplete = isDailyChallengeComplete
    }
}
