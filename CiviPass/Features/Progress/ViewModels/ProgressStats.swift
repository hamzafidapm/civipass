import Foundation

/// Pure calculation over `QuizAttempt` records. Deliberately has no SwiftData
/// dependency so it can be unit tested against plain in-memory model instances.
enum ProgressStats {
    struct Summary {
        let totalQuizzes: Int
        let overallAccuracy: Double
        let currentStreakDays: Int
        let categoryBreakdown: [CategoryBreakdown]
    }

    struct CategoryBreakdown: Identifiable {
        let category: StudyCategory?
        let attemptCount: Int
        let accuracy: Double

        var id: String { category?.rawValue ?? "Mixed" }
        var displayName: String { category?.rawValue ?? "Mixed" }
    }

    static func summarize(_ attempts: [QuizAttempt], today: Date = Date(), calendar: Calendar = .current) -> Summary {
        Summary(
            totalQuizzes: attempts.count,
            overallAccuracy: accuracy(of: attempts),
            currentStreakDays: currentStreak(attempts, today: today, calendar: calendar),
            categoryBreakdown: categoryBreakdown(of: attempts)
        )
    }

    static func accuracy(of attempts: [QuizAttempt]) -> Double {
        let totalQuestions = attempts.reduce(0) { $0 + $1.totalQuestions }
        guard totalQuestions > 0 else { return 0 }
        let totalCorrect = attempts.reduce(0) { $0 + $1.correctCount }
        return Double(totalCorrect) / Double(totalQuestions)
    }

    /// Consecutive days, ending today, with at least one attempt. Zero if there's no attempt today.
    static func currentStreak(_ attempts: [QuizAttempt], today: Date = Date(), calendar: Calendar = .current) -> Int {
        guard !attempts.isEmpty else { return 0 }

        let attemptDays = Set(attempts.map { calendar.startOfDay(for: $0.date) })
        var streak = 0
        var cursor = calendar.startOfDay(for: today)

        while attemptDays.contains(cursor) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previousDay
        }

        return streak
    }

    static func categoryBreakdown(of attempts: [QuizAttempt]) -> [CategoryBreakdown] {
        let grouped = Dictionary(grouping: attempts) { $0.category }
        return grouped
            .map { category, attempts in
                CategoryBreakdown(category: category, attemptCount: attempts.count, accuracy: accuracy(of: attempts))
            }
            .sorted { ($0.category?.rawValue ?? "") < ($1.category?.rawValue ?? "") }
    }
}
