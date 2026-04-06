import SwiftUI

struct NodeRunCard: View {
    let node: FlowNode
    let secondsElapsed: Int

    var body: some View {
        VStack(spacing: 0) {
            if node.emoji != nil || node.imageData != nil {
                CustomIcon(emoji: node.emoji, imageData: node.imageData, size: 80)
                    .padding(.bottom, 20)
            }

            Text(node.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            if !node.notes.isEmpty {
                Text(node.notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
            } else {
                Spacer().frame(height: 24)
            }

            timerView
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.07), radius: 20, x: 0, y: 8)
        )
    }

    @ViewBuilder
    private var timerView: some View {
        if let duration = node.durationMinutes {
            let totalSecs = duration * 60
            let remaining = max(0, totalSecs - secondsElapsed)
            let fraction = Double(remaining) / Double(totalSecs)

            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: fraction)
                        .stroke(
                            fraction < 0.2 ? Color.red : Color.accentColor,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: fraction)
                }
                .frame(width: 72, height: 72)
                .overlay {
                    Text(flowTimeString(remaining))
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundStyle(fraction < 0.2 ? .red : .primary)
                }

                if secondsElapsed > totalSecs {
                    Text("Time's up!")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.red)
                }
            }
        } else {
            VStack(spacing: 4) {
                Text(flowTimeString(secondsElapsed))
                    .font(.system(size: 32, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text("elapsed")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
