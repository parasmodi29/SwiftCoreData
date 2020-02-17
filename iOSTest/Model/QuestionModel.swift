
import Foundation

struct Questions: Codable {
    var id: String
    var title: String?
    var answers: [Answers]
    var isAttempt: Bool
}

struct Answers: Codable {
    var title: String?
    var isSelected: Bool
    var isCorrect: Bool
}
