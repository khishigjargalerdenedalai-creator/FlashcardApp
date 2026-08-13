import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedTab: AppTab

    @Query private var spaces: [LearningSpace]
    @Query private var cards: [Card]

    private var dueCount: Int {
        let now = Date()
        return cards.filter { ($0.nextReviewAt ?? .distantPast) <= now }.count
    }

    private var retention: Double {
        SpacedRepetitionEngine.accuracyPercentage(of: cards)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    greeting
                    retentionCard

                    Button {
                        selectedTab = .review
                    } label: {
                        Label("Давтаж эхлэх", systemImage: "play.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(dueCount == 0)

                    spacesSection
                }
                .padding()
            }
            .navigationTitle("Нүүр")
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Сайн байна уу")
                .font(.title2.bold())
            Text(dueCount > 0 ? "Өнөөдөр \(dueCount) карт хүлээж байна" : "Өнөөдөр давтах карт алга")
                .foregroundStyle(.secondary)
        }
    }

    private var retentionCard: some View {
        VStack(spacing: 4) {
            Text("\(Int(retention.rounded()))%")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            Text("Тогтвортой эзэмшилтийн хувь")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var spacesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning Space-үүд")
                .font(.headline)

            if spaces.isEmpty {
                Text("Одоогоор Space алга. Сан таб дээрээс үүсгэнэ үү.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(spaces) { space in
                    spaceRow(space)
                }
            }
        }
    }

    private func spaceRow(_ space: LearningSpace) -> some View {
        let mastered = SpacedRepetitionEngine.masteredPercentage(of: space.cards)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(space.name)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(Int(mastered.rounded()))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: mastered, total: 100)
        }
        .padding(.vertical, 4)
    }
}
