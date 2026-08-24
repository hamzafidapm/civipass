import Foundation
import SwiftData

enum QuestionRepository {
    enum SeedError: Error {
        case resourceNotFound
        case invalidOptionCount(Int)
        case correctAnswerIndexOutOfRange(Int, optionCount: Int)
        case unknownCategory(String)
        case unknownDifficulty(String)
    }

    /// Loads `questions.json` into the store, but only if it's currently empty.
    static func seedIfNeeded(context: ModelContext) throws {
        let existingCount = try context.fetchCount(FetchDescriptor<Question>())
        guard existingCount == 0 else { return }

        let seeds = try loadSeedQuestions()
        for (index, seed) in seeds.enumerated() {
            do {
                context.insert(try makeQuestion(from: seed))
            } catch {
                print("QuestionRepository: skipping invalid seed question at index \(index) - \(error)")
            }
        }
        try context.save()
    }

    // #Predicate can't capture an enum constant directly (SwiftDataError.unsupportedPredicate),
    // and the full question bank is small (the entire USCIS test corpus is ~100-128 questions),
    // so these filter in Swift after an unpredicated fetch rather than routing through the predicate macro.
    static func questions(in category: StudyCategory, context: ModelContext) throws -> [Question] {
        try context.fetch(FetchDescriptor<Question>()).filter { $0.category == category }
    }

    static func questions(difficulty: QuestionDifficulty, context: ModelContext) throws -> [Question] {
        try context.fetch(FetchDescriptor<Question>()).filter { $0.difficulty == difficulty }
    }

    static func randomQuizSet(count: Int, context: ModelContext) throws -> [Question] {
        let all = try context.fetch(FetchDescriptor<Question>())
        return Array(all.shuffled().prefix(count))
    }

    // MARK: - Seed loading

    private static func loadSeedQuestions() throws -> [QuestionSeed] {
        guard let url = Bundle(for: Question.self).url(forResource: "questions", withExtension: "json") else {
            throw SeedError.resourceNotFound
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([QuestionSeed].self, from: data)
    }

    private static func makeQuestion(from seed: QuestionSeed) throws -> Question {
        guard (2...6).contains(seed.options.count) else {
            throw SeedError.invalidOptionCount(seed.options.count)
        }
        guard seed.options.indices.contains(seed.correctAnswerIndex) else {
            throw SeedError.correctAnswerIndexOutOfRange(seed.correctAnswerIndex, optionCount: seed.options.count)
        }
        guard let category = StudyCategory(rawValue: seed.category) else {
            throw SeedError.unknownCategory(seed.category)
        }
        guard let difficulty = QuestionDifficulty(rawValue: seed.difficulty) else {
            throw SeedError.unknownDifficulty(seed.difficulty)
        }

        return Question(
            id: seed.id ?? UUID(),
            category: category,
            questionText: seed.questionText,
            options: seed.options,
            correctAnswerIndex: seed.correctAnswerIndex,
            explanation: seed.explanation,
            difficulty: difficulty,
            source: seed.source
        )
    }
}
