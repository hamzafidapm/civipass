import Foundation
import Observation
import SwiftData

@Observable
final class QuizViewModel {
    private(set) var questions: [Question] = []
    private(set) var currentIndex = 0
    private(set) var correctCount = 0
    private(set) var selectedOptionIndex: Int?
    private(set) var isFinished = false
    var errorMessage: String?

    var currentQuestion: Question? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    var progressText: String {
        guard !questions.isEmpty else { return "" }
        return "\(min(currentIndex + 1, questions.count)) of \(questions.count)"
    }

    var scorePercentage: Int {
        guard !questions.isEmpty else { return 0 }
        return Int((Double(correctCount) / Double(questions.count) * 100).rounded())
    }

    /// Production entry point: pulls a fresh random quiz set from the repository.
    func start(context: ModelContext, count: Int = 10) {
        do {
            let quizQuestions = try QuestionRepository.randomQuizSet(count: count, context: context)
            errorMessage = quizQuestions.isEmpty ? "No questions available yet." : nil
            configure(with: quizQuestions)
        } catch {
            errorMessage = "Couldn't load quiz: \(error.localizedDescription)"
            configure(with: [])
        }
    }

    /// Resets scoring state against a fixed question set. Separated from `start(context:)`
    /// so scoring logic can be unit tested without a SwiftData context.
    func configure(with questions: [Question]) {
        self.questions = questions
        currentIndex = 0
        correctCount = 0
        selectedOptionIndex = nil
        isFinished = questions.isEmpty
    }

    func selectAnswer(_ index: Int) {
        guard selectedOptionIndex == nil, let question = currentQuestion else { return }
        selectedOptionIndex = index
        if index == question.correctAnswerIndex {
            correctCount += 1
        }
    }

    func advance() {
        guard selectedOptionIndex != nil else { return }
        selectedOptionIndex = nil
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            isFinished = true
        }
    }
}
