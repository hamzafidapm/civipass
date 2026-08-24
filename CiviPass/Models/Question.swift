import Foundation
import SwiftData

@Model
final class Question {
    var id: UUID
    var category: StudyCategory
    var questionText: String
    var options: [String]
    var correctAnswerIndex: Int
    var explanation: String?
    var difficulty: QuestionDifficulty
    var source: String?

    init(
        id: UUID = UUID(),
        category: StudyCategory,
        questionText: String,
        options: [String],
        correctAnswerIndex: Int,
        explanation: String? = nil,
        difficulty: QuestionDifficulty,
        source: String? = nil
    ) {
        self.id = id
        self.category = category
        self.questionText = questionText
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
        self.difficulty = difficulty
        self.source = source
    }
}
