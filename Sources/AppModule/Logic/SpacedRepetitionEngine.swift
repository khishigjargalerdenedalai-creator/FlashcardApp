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
