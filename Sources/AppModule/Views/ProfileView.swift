import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var spaces: [LearningSpace]
    @Query private var cards: [Card]

    private var totalReviews: Int {
        cards.reduce(0) { $0 + $1.reviewCount }
    }

    private var totalCorrect: Int {
        cards.reduce(0) { $0 + $1.correctCount }
    }

    private var accuracy: Double {
        guard totalReviews > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalReviews) * 100
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Ерөнхий тойм") {
                    statRow("Learning Space", "\(spaces.count)")
                    statRow("Нийт карт", "\(cards.count)")
                    statRow("Хийсэн давталт", "\(totalReviews)")
                    statRow("Зөв хариултын хувь", String(format: "%.0f%%", accuracy))
                }
            }
            .navigationTitle("Профайл")
        }
    }

    private func statRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
