import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LearningSpace.createdAt) private var spaces: [LearningSpace]

    @State private var isAddingSpace = false
    @State private var newSpaceName = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(spaces) { space in
                    NavigationLink(value: space) {
                        spaceCard(space)
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(
                        EdgeInsets(
                            top: Metrics.spacingS,
                            leading: Metrics.spacingM,
                            bottom: Metrics.spacingS,
                            trailing: Metrics.spacingM
                        )
                    )
                }
                .onDelete(perform: deleteSpaces)
            }
            .listStyle(.plain)
            .navigationTitle("Сан")
            .navigationDestination(for: LearningSpace.self) { space in
                SpaceDetailView(space: space)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingSpace = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Шинэ Learning Space", isPresented: $isAddingSpace) {
                TextField("Нэр", text: $newSpaceName)
                Button("Үүсгэх", action: addSpace)
                Button("Цуцлах", role: .cancel) { newSpaceName = "" }
            }
            .overlay {
                if spaces.isEmpty {
                    ContentUnavailableView(
                        "Learning Space алга",
                        systemImage: "square.stack",
                        description: Text("Эхлээд шинэ Space үүсгэнэ үү")
                    )
                }
            }
        }
    }

    private func spaceCard(_ space: LearningSpace) -> some View {
        let mastered = SpacedRepetitionEngine.masteredPercentage(of: space.cards)
        return VStack(alignment: .leading, spacing: Metrics.spacingS) {
            HStack {
                Text(space.name)
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                Spacer()
                Text("\(space.cards.count) карт")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            GradientProgressBar(progress: mastered)
            Text("\(Int(mastered.rounded()))% эзэмшсэн")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(Metrics.spacingM)
        .surfaceCard()
    }

    private func addSpace() {
        let trimmed = newSpaceName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        modelContext.insert(LearningSpace(name: trimmed))
        newSpaceName = ""
    }

    private func deleteSpaces(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(spaces[index])
        }
    }
}

private struct SpaceDetailView: View {
    var space: LearningSpace

    @Environment(\.modelContext) private var modelContext
    @State private var isAddingCard = false
    @State private var editingCard: Card?
    @State private var searchText = ""

    private var filteredCards: [Card] {
        guard !searchText.isEmpty else { return space.cards }
        let query = searchText.lowercased()
        return space.cards.filter {
            $0.front.lowercased().contains(query) || $0.back.lowercased().contains(query)
        }
    }

    var body: some View {
        List {
            ForEach(filteredCards) { card in
                Button {
                    editingCard = card
                } label: {
                    cardRow(card)
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(
                    EdgeInsets(
                        top: Metrics.spacingS,
                        leading: Metrics.spacingM,
                        bottom: Metrics.spacingS,
                        trailing: Metrics.spacingM
                    )
                )
            }
            .onDelete(perform: deleteCards)
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Карт хайх")
        .navigationTitle(space.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAddingCard = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingCard) {
            CardEditView(space: space)
        }
        .sheet(item: $editingCard) { card in
            CardEditView(space: space, card: card)
        }
        .overlay {
            if space.cards.isEmpty {
                ContentUnavailableView(
                    "Карт алга",
                    systemImage: "rectangle.on.rectangle",
                    description: Text("+ товчоор шинэ карт нэмнэ үү")
                )
            } else if filteredCards.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
    }

    private func cardRow(_ card: Card) -> some View {
        VStack(alignment: .leading, spacing: Metrics.spacingS) {
            Text(card.front)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(.primary)
            Text(card.back)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Metrics.spacingM)
        .surfaceCard()
    }

    private func deleteCards(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredCards[index])
        }
    }
}
