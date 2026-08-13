import SwiftUI
import SwiftData

struct CardEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let space: LearningSpace
    var card: Card?

    @State private var front = ""
    @State private var back = ""
    @State private var explanation = ""
    @State private var tagsText = ""

    private var isEditing: Bool { card != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Урд тал") {
                    TextField("Асуулт / Үг", text: $front, axis: .vertical)
                }
                Section("Ард тал") {
                    TextField("Хариулт", text: $back, axis: .vertical)
                }
                Section("Тайлбар (заавал биш)") {
                    TextField("Нэмэлт тайлбар", text: $explanation, axis: .vertical)
                }
                Section("Шошго (таслалаар тусгаарлана)") {
                    TextField("жишээ: verb, A1", text: $tagsText)
                }
            }
            .navigationTitle(isEditing ? "Карт засах" : "Шинэ карт")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Цуцлах") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Хадгалах", action: save)
                        .disabled(
                            front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        )
                }
            }
            .onAppear(perform: loadExistingCard)
        }
    }

    private func loadExistingCard() {
        guard let card else { return }
        front = card.front
        back = card.back
        explanation = card.explanation
        tagsText = card.tags.joined(separator: ", ")
    }

    private func save() {
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if let card {
            card.front = front
            card.back = back
            card.explanation = explanation
            card.tags = tags
        } else {
            let newCard = Card(front: front, back: back, explanation: explanation, tags: tags, space: space)
            modelContext.insert(newCard)
        }
        dismiss()
    }
}
