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
                VStack(alignment: .leading, spacing: Metrics.spacingL) {
                    greeting
                    retentionCard

                    Button {
                        selectedTab = .review
                    } label: {
                        Label("Давтаж эхлэх", systemImage: "play.fill")
                            .font(.system(.headline, design: .rounded).weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Metrics.spacingS)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: Metrics.cornerRadius))
                    .controlSize(.large)
                    .disabled(dueCount == 0)

                    spacesSection
                }
                .padding(Metrics.spacingM)
            }
            .navigationTitle("Нүүр")
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: Metrics.spacingS) {
            Text("Сайн байна уу")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
            Text(dueCount > 0 ? "Өнөөдөр \(dueCount) карт хүлээж байна" : "Өнөөдөр давтах карт алга")
                .foregroundStyle(.secondary)
        }
    }

    private var retentionCard: some View {
        VStack(spacing: Metrics.spacingS) {
            Text("\(Int(retention.rounded()))%")
                .font(.system(size: 52, weight: .bold, design: .rounded))
            Text("Тогтвортой эзэмшилтийн хувь")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Metrics.spacingL)
        .surfaceCard()
    }

    private var spacesSection: some View {
        VStack(alignment: .leading, spacing: Metrics.spacingM) {
            Text("Learning Space-үүд")
                .font(.system(.title3, design: .rounded).weight(.semibold))

            if spaces.isEmpty {
                Text("Одоогоор Space алга. Сан таб дээрээс үүсгэнэ үү.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: Metrics.spacingS) {
                    ForEach(spaces) { space in
                        spaceRow(space)
                    }
                }
            }
        }
    }

    private func spaceRow(_ space: LearningSpace) -> some View {
        let mastered = SpacedRepetitionEngine.masteredPercentage(of: space.cards)
        return VStack(alignment: .leading, spacing: Metrics.spacingS) {
            HStack {
                Text(space.name)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                Spacer()
                Text("\(Int(mastered.rounded()))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            GradientProgressBar(progress: mastered)
        }
        .padding(Metrics.spacingM)
        .surfaceCard()
    }
}
