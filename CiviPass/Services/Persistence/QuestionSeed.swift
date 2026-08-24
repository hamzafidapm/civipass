import Foundation

/// Wire format for one entry in the bundled `questions.json` seed file.
struct QuestionSeed: Decodable {
    let id: UUID?
    let category: String
    let questionText: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String?
    let difficulty: String
    let source: String?
}
