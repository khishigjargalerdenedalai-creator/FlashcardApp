import Foundation
import SwiftData

@Model
final class Card {
    var id: UUID
    var front: String
    var back: String
    var explanation: String
    var tags: [String]
    var createdAt: Date
    var lastReviewedAt: Date?
    var nextReviewAt: Date?
    var reviewCount: Int
    var correctCount: Int
    var incorrectCount: Int
    var lapseCount: Int
    var stability: Double
    var difficulty: Double

    var space: LearningSpace?

    var spaceId: UUID? { space?.id }

    init(
        front: String,
        back: String,
        explanation: String = "",
        tags: [String] = [],
        space: LearningSpace? = nil
    ) {
        self.id = UUID()
        self.front = front
        self.back = back
        self.explanation = explanation
        self.tags = tags
        self.createdAt = Date()
        self.lastReviewedAt = nil
        self.nextReviewAt = Date()
        self.reviewCount = 0
        self.correctCount = 0
        self.incorrectCount = 0
        self.lapseCount = 0
        self.stability = 1.0
        self.difficulty = 5.0
        self.space = space
    }
}
