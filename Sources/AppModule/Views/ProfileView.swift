import SwiftUI
import SwiftData
import Charts

struct ProfileView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    @Query private var spaces: [LearningSpace]
    @Query private var cards: [Card]
    @Query private var reviewLogs: [ReviewLog]

    private var masteredCount: Int {
        cards.filter { SpacedRepetitionEngine.masteryLevel(for: $0) == .mastered }.count
    }

    private var learningCount: Int {
        cards.filter { SpacedRepetitionEngine.masteryLevel(for: $0) == .learning }.count
    }

    private struct DailyCount: Identifiable {
        let id = UUID()
        let day: Date
        let count: Int
    }

    private var weeklyReviewCounts: [DailyCount] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let count = reviewLogs.filter { calendar.isDate($0.date, inSameDayAs: day) }.count
            return DailyCount(day: day, count: count)
        }
    }

    private struct SpaceAccuracy: Identifiable {
        let id: UUID
        let name: String
        let accuracy: Double
    }

    private var difficultSpaces: [SpaceAccuracy] {
        spaces
            .compactMap { space -> SpaceAccuracy? in
                let totalReviews = space.cards.reduce(0) { $0 + $1.reviewCount }
                guard totalReviews > 0 else { return nil }
                let accuracy = SpacedRepetitionEngine.accuracyPercentage(of: space.cards)
                return SpaceAccuracy(id: space.id, name: space.name, accuracy: accuracy)
            }
            .filter { $0.accuracy < 80 }
            .sorted { $0.accuracy < $1.accuracy }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Ерөнхий тойм") {
                    statRow("Нийт карт", "\(cards.count)")
                    statRow("Эзэмшсэн", "\(masteredCount)")
                    statRow("Суралцаж буй", "\(learningCount)")
                }

                Section("Долоо хоногийн давталт") {
                    Chart(weeklyReviewCounts) { item in
                        BarMark(
                            x: .value("Өдөр", item.day, unit: .day),
                            y: .value("Тоо", item.count)
                        )
                        .foregroundStyle(.blue)
                    }
                    .frame(height: 160)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisValueLabel(format: .dateTime.weekday(.narrow))
                        }
                    }
                    .padding(.vertical, 4)
                }

                if !difficultSpaces.isEmpty {
                    Section("Хэцүү сэдвүүд") {
                        ForEach(difficultSpaces) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text("\(Int(item.accuracy.rounded()))%")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Тохиргоо") {
                    Toggle(isOn: $isDarkMode) {
                        Label("Харанхуй горим", systemImage: "moon.fill")
                    }
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
