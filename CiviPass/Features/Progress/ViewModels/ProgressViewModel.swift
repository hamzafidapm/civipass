import Foundation
import Observation
import SwiftData

@Observable
final class ProgressViewModel {
    private(set) var summary = ProgressStats.summarize([])
    private(set) var errorMessage: String?

    func load(context: ModelContext) {
        do {
            let attempts = try QuizAttemptRepository.fetchAll(context: context)
            summary = ProgressStats.summarize(attempts)
            errorMessage = nil
        } catch {
            summary = ProgressStats.summarize([])
            errorMessage = "Couldn't load progress: \(error.localizedDescription)"
        }
    }
}
