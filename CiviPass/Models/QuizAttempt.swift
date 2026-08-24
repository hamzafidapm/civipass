import Foundation
import SwiftData

@Model
final class QuizAttempt {
    var id: UUID
    var date: Date
    var category: StudyCategory?
    var totalQuestions: Int
    var correctCount: Int

    init(
        id: UUID = UUID(),
        date: Date,
        category: StudyCategory? = nil,
        totalQuestions: Int,
        correctCount: Int
    ) {
        self.id = id
        self.date = date
        self.category = category
        self.totalQuestions = totalQuestions
        self.correctCount = correctCount
    }
}
