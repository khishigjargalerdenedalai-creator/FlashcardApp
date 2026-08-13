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

    private var overallMastery: Double {
        SpacedRepetitionEngine.masteredPercentage(of: cards)
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
                Section {
                    HStack(spacing: Metrics.spacingL) {
                        CircularProgressGauge(progress: overallMastery)
                            .frame(width: 84, height: 84)

                        VStack(alignment: .leading, spacing: Metrics.spacingS) {
                            statRow("Нийт карт", "\(cards.count)")
                            statRow("Эзэмшсэн", "\(masteredCount)")
                            statRow("Суралцаж буй", "\(learningCount)")
                        }
                    }
                    .padding(.vertical, Metrics.spacingS)
                } header: {
                    Text("Ерөнхий тойм")
                }

                Section("Долоо хоногийн давталт") {
                    Chart(weeklyReviewCounts) { item in
                        BarMark(
                            x: .value("Өдөр", item.day, unit: .day),
                            y: .value("Тоо", item.count)
                        )
                        .foregroundStyle(Color.accentColor)
                        .cornerRadius(4)
                    }
                    .frame(height: 160)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisValueLabel(format: .dateTime.weekday(.narrow))
                        }
                    }
                    .padding(.vertical, Metrics.spacingS)
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
            .listStyle(.insetGrouped)
            .navigationTitle("Профайл")
        }
    }

    private func statRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .rounded).weight(.semibold))
        }
    }
}
