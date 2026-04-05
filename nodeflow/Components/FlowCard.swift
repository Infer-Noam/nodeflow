import SwiftUI

struct FlowCard: View {
    let flow: Flow

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.cardSpacing) {
            HStack(spacing: AppConstants.Layout.cardSpacing) {
                if flow.emoji != nil || flow.imageData != nil {
                    CustomIcon(emoji: flow.emoji, imageData: flow.imageData, size: AppConstants.IconSize.medium)
                }
                Text(flow.title)
                    .font(.headline)
                Spacer()
                if flow.isRecurring {
                    Label(flow.recurrenceFrequency.rawValue, systemImage: "repeat")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !flow.notes.isEmpty {
                Text(flow.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 16) {
                if let time = flow.scheduledTime {
                    Label(time.formatted(date: .omitted, time: .shortened), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let mins = flow.durationMinutes {
                    Label("\(mins) min", systemImage: "timer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !flow.nodes.isEmpty {
                    Text("\(flow.nodes.count) nodes")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
