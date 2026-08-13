import SwiftUI

struct CardFlipView: View {
    let front: String
    let back: String
    let explanation: String
    @Binding var isFlipped: Bool

    var body: some View {
        ZStack {
            face(text: front)
                .opacity(isFlipped ? 0 : 1)

            face(text: back, explanation: explanation)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: isFlipped)
        .contentShape(Rectangle())
        .onTapGesture {
            isFlipped.toggle()
        }
    }

    private func face(text: String, explanation: String = "") -> some View {
        VStack(spacing: 12) {
            Text(text)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            if !explanation.isEmpty {
                Text(explanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.quaternary)
        )
    }
}
