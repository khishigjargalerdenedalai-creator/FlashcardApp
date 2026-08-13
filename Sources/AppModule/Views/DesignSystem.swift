import SwiftUI

enum Metrics {
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let cornerRadius: CGFloat = 18
}

extension View {
    func surfaceCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

struct GradientProgressBar: View {
    var progress: Double
    var height: CGFloat = 10

    private var clampedProgress: Double {
        min(max(progress / 100, 0), 1)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.tertiarySystemFill))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.55)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * clampedProgress)
            }
        }
        .frame(height: height)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: progress)
    }
}

struct CircularProgressGauge: View {
    var progress: Double
    var lineWidth: CGFloat = 10

    private var clampedProgress: Double {
        min(max(progress / 100, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.tertiarySystemFill), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    LinearGradient(
                        colors: [.accentColor, .accentColor.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.85), value: progress)

            Text("\(Int(progress.rounded()))%")
                .font(.system(.headline, design: .rounded).weight(.bold))
        }
    }
}
