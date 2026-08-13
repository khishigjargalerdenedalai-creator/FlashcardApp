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

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("\(dueCount)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                    Text("карт давтах хугацаатай")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 32)

                if dueCount > 0 {
                    Button {
                        selectedTab = .review
                    } label: {
                        Label("Давталт эхлүүлэх", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 32)
                }

                VStack(spacing: 12) {
                    statRow(title: "Learning Space", value: "\(spaces.count)")
                    statRow(title: "Нийт карт", value: "\(cards.count)")
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .navigationTitle("Нүүр")
        }
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
