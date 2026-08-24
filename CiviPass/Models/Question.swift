import Foundation
import SwiftData

@Model
final class Question {
    var id: UUID
    var prompt: String
    var choices: [String]
    var correctChoiceIndex: Int
    var category: StudyCategory
    var isBookmarked: Bool
    var timesAnsweredCorrectly: Int
    var timesAnsweredIncorrectly: Int

    init(
        id: UUID = UUID(),
        prompt: String,
        choices: [String],
        correctChoiceIndex: Int,
        category: StudyCategory,
        isBookmarked: Bool = false,
        timesAnsweredCorrectly: Int = 0,
        timesAnsweredIncorrectly: Int = 0
    ) {
        self.id = id
        self.prompt = prompt
        self.choices = choices
        self.correctChoiceIndex = correctChoiceIndex
        self.category = category
        self.isBookmarked = isBookmarked
        self.timesAnsweredCorrectly = timesAnsweredCorrectly
        self.timesAnsweredIncorrectly = timesAnsweredIncorrectly
    }
}
