import SwiftUI
import SwiftData

struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext
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
                    .padding(.horizontal, Metrics.spacingM)
                    Spacer()

                    if isFlipped {
                        ratingButtons(for: card)
                            .padding(.bottom, Metrics.spacingL)
                    } else {
                        Text("Хариултыг харахын тулд картан дээр товшино уу")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, Metrics.spacingL)
                    }
                } else {
                    emptyState
                }
            }
            .navigationTitle("Давтах")
            .onAppear(perform: loadQueueIfNeeded)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Metrics.spacingM) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)
            Text("Өнөөдрийн давталт дууслаа")
                .font(.system(.headline, design: .rounded).weight(.semibold))
        }
        .frame(maxHeight: .infinity)
    }

    private func ratingButtons(for card: Card) -> some View {
        HStack(spacing: Metrics.spacingS) {
            ratingButton("Дахин", color: .red) { rate(card, .again) }
            ratingButton("Хэцүү", color: .orange) { rate(card, .hard) }
            ratingButton("Зөв", color: Color.accentColor) { rate(card, .good) }
            ratingButton("Амархан", color: .green) { rate(card, .easy) }
        }
        .padding(.horizontal, Metrics.spacingM)
    }

    private func ratingButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Metrics.spacingS)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: Metrics.cornerRadius / 1.5))
        .tint(color)
    }

    private func rate(_ card: Card, _ rating: ReviewRating) {
        SpacedRepetitionEngine.review(card, rating: rating)
        modelContext.insert(ReviewLog(date: Date()))
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
