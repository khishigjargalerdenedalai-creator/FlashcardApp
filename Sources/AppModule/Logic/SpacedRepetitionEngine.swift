import Foundation

enum ReviewRating {
    case again
    case hard
    case good
    case easy
}

enum SpacedRepetitionEngine {
    static func review(_ card: Card, rating: ReviewRating, now: Date = Date()) {
        card.reviewCount += 1
        card.lastReviewedAt = now

        switch rating {
        case .again:
            card.incorrectCount += 1
            card.lapseCount += 1
        case .hard, .good, .easy:
            card.correctCount += 1
        }

        updateDifficulty(card, rating: rating)
        updateStability(card, rating: rating)
        card.nextReviewAt = nextReviewDate(card, rating: rating, now: now)
    }

    private static func updateDifficulty(_ card: Card, rating: ReviewRating) {
        let delta: Double
        switch rating {
        case .again: delta = 1.0
        case .hard: delta = 0.4
        case .good: delta = 0.0
        case .easy: delta = -0.6
        }
        card.difficulty = min(10, max(1, card.difficulty + delta))
    }

    private static func updateStability(_ card: Card, rating: ReviewRating) {
        // difficulty өндөр байх тусам ил (ease) багасаж, stability удаан өснө.
        let ease = 2.6 - (card.difficulty - 5) * 0.08

        switch rating {
        case .again:
            card.stability = max(0.5, card.stability * 0.5)
        case .hard:
            card.stability *= 1.2
        case .good:
            card.stability *= max(1.3, ease)
        case .easy:
            card.stability *= max(1.5, ease) * 1.3
        }
    }

    private static func nextReviewDate(_ card: Card, rating: ReviewRating, now: Date) -> Date {
        guard rating != .again else {
            return now.addingTimeInterval(10 * 60)
        }
        let intervalDays = max(1, Int(card.stability.rounded()))
        return Calendar.current.date(byAdding: .day, value: intervalDays, to: now) ?? now
    }
}

enum MasteryLevel {
    case new
    case learning
    case mastered
}

extension SpacedRepetitionEngine {
    /// Stability (өдрөөр) энэ түвшнээс дээш хүрвэл карт "эзэмшсэн" гэж үзнэ.
    static let masteryStabilityThreshold: Double = 21

    static func masteryLevel(for card: Card) -> MasteryLevel {
        if card.reviewCount == 0 { return .new }
        return card.stability >= masteryStabilityThreshold ? .mastered : .learning
    }

    static func masteredPercentage(of cards: [Card]) -> Double {
        guard !cards.isEmpty else { return 0 }
        let masteredCount = cards.filter { masteryLevel(for: $0) == .mastered }.count
        return Double(masteredCount) / Double(cards.count) * 100
    }

    static func accuracyPercentage(of cards: [Card]) -> Double {
        let reviewed = cards.filter { $0.reviewCount > 0 }
        let totalReviews = reviewed.reduce(0) { $0 + $1.reviewCount }
        guard totalReviews > 0 else { return 0 }
        let totalCorrect = reviewed.reduce(0) { $0 + $1.correctCount }
        return Double(totalCorrect) / Double(totalReviews) * 100
    }
}
