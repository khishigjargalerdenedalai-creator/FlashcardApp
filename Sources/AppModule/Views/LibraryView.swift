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
                        VStack(alignment: .leading, spacing: 4) {
                            Text(space.name)
                                .font(.headline)
                            Text("\(space.cards.count) карт")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteSpaces)
            }
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

    var body: some View {
        List {
            ForEach(space.cards) { card in
                Button {
                    editingCard = card
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.front)
                            .foregroundStyle(.primary)
                        Text(card.back)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteCards)
        }
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
            }
        }
    }

    private func deleteCards(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(space.cards[index])
        }
    }
}
