import SwiftUI
import SwiftData

struct ReviewView: View {
    @Query private var allCards: [Card]

    @State private var queue: [Card] = []
    @State private var isFlipped = false
    @State private var didLoadQueue = false

    var body: some View {
        NavigationStack {
            VStack {
                if let card = queue.first {
                    Spacer()
                    CardFlipView(
                        front: card.front,
                        back: card.back,
                        explanation: card.explanation,
                        isFlipped: $isFlipped
                    )
                    .padding(.horizontal)
                    Spacer()

                    if isFlipped {
                        ratingButtons(for: card)
                            .padding(.bottom, 24)
                    } else {
                        Text("Хариултыг харахын тулд картан дээр товшино уу")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 24)
                    }
                } else {
                    emptyState
                }
            }
            .navigationTitle("Давталт")
            .onAppear(perform: loadQueueIfNeeded)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("Өнөөдөр давтах карт алга")
                .font(.headline)
        }
        .frame(maxHeight: .infinity)
    }

    private func ratingButtons(for card: Card) -> some View {
        HStack(spacing: 10) {
            ratingButton("Дахин", color: .red) { rate(card, .again) }
            ratingButton("Хэцүү", color: .orange) { rate(card, .hard) }
            ratingButton("Сайн", color: .blue) { rate(card, .good) }
            ratingButton("Амархан", color: .green) { rate(card, .easy) }
        }
        .padding(.horizontal)
    }

    private func ratingButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
    }

    private func rate(_ card: Card, _ rating: ReviewRating) {
        SpacedRepetitionEngine.review(card, rating: rating)
        isFlipped = false
        queue.removeFirst()
    }

    private func loadQueueIfNeeded() {
        guard !didLoadQueue else { return }
        didLoadQueue = true
        let now = Date()
        queue = allCards.filter { ($0.nextReviewAt ?? .distantPast) <= now }
    }
}
