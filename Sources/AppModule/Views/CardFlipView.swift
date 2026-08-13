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
                .rotation3DEffect(
                    .degrees(180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.4
                )
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.4
        )
        .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 10)
        .animation(.spring(response: 0.5, dampingFraction: 0.72), value: isFlipped)
        .contentShape(Rectangle())
        .onTapGesture {
            isFlipped.toggle()
        }
    }

    private func face(text: String, explanation: String = "") -> some View {
        VStack(spacing: Metrics.spacingS) {
            Text(text)
                .font(.system(.title2, design: .rounded).weight(.semibold))
                .multilineTextAlignment(.center)

            if !explanation.isEmpty {
                Text(explanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Metrics.spacingL)
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.25))
        )
    }
}
