import Foundation
import Observation
import SwiftData

@Observable
final class StudyViewModel {
    var selectedCategory: StudyCategory?
    private(set) var questions: [Question] = []
    private(set) var errorMessage: String?

    func loadQuestions(context: ModelContext) {
        do {
            if let category = selectedCategory {
                questions = try QuestionRepository.questions(in: category, context: context)
            } else {
                questions = try context.fetch(FetchDescriptor<Question>())
            }
            errorMessage = nil
        } catch {
            questions = []
            errorMessage = "Couldn't load questions: \(error.localizedDescription)"
        }
    }
}
