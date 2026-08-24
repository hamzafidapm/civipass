import Foundation
import SwiftData

enum QuizAttemptRepository {
    static func save(
        totalQuestions: Int,
        correctCount: Int,
        category: StudyCategory? = nil,
        date: Date = Date(),
        context: ModelContext
    ) throws {
        let attempt = QuizAttempt(
            date: date,
            category: category,
            totalQuestions: totalQuestions,
            correctCount: correctCount
        )
        context.insert(attempt)
        try context.save()
    }

    static func fetchAll(context: ModelContext) throws -> [QuizAttempt] {
        try context.fetch(FetchDescriptor<QuizAttempt>())
    }
}
