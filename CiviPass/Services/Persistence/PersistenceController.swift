import SwiftData

enum PersistenceController {
    static let schema = Schema([
        Question.self,
        StudyStreak.self,
        QuizAttempt.self
    ])

    static let sharedModelContainer: ModelContainer = {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    static let previewModelContainer: ModelContainer = {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }()
}
