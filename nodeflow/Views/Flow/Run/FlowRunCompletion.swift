import SwiftUI

struct FlowRunCompletion: View {
    let flow: Flow
    let nodeCount: Int
    let secondsElapsed: Int
    let totalDuration: Int?
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 140, height: 140)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                    .symbolRenderingMode(.hierarchical)
            }
            .transition(.scale.combined(with: .opacity))

            VStack(spacing: 8) {
                Text("Flow Complete!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text(flow.title)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                statRow(icon: "checkmark.square.fill", label: "Nodes completed", value: "\(nodeCount)")
                statRow(icon: "clock.fill", label: "Total time", value: flowTimeString(secondsElapsed))
                if let total = totalDuration {
                    let diff = secondsElapsed - (total * 60)
                    let label = diff >= 0
                        ? "\(flowTimeString(abs(diff))) over"
                        : "\(flowTimeString(abs(diff))) under"
                    statRow(icon: "timer", label: "vs. estimated", value: label)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .padding(.horizontal, 32)

            Spacer()

            Button(action: onDone) {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Capsule().fill(Color.accentColor))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
    }
}
