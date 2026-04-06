
import SwiftUI

struct FlowDetailView: View {
    @Bindable var flow: Flow
    @State private var showingEdit = false

    var sortedNodes: [FlowNode] {
        flow.nodes.sorted { $0.order < $1.order }
    }


    var body: some View {
        List {
            if flow.scheduledTime != nil || flow.durationMinutes != nil || flow.isRecurring {
                Section {
                    if let time = flow.scheduledTime {
                        LabeledContent("Start time", value: time.formatted(date: .omitted, time: .shortened))
                    }
                    if let duration = flow.durationMinutes {
                        LabeledContent("Duration", value: "\(duration) min")
                    }
                    if flow.isRecurring {
                        LabeledContent("Recurring", value: (flow.recurrenceFrequency ?? .daily).rawValue)
                    }
                }
            }

            if !flow.notes.isEmpty {
                Section("Notes") {
                    Text(flow.notes)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                if flow.nodes.isEmpty {
                    Text("No nodes yet — tap Edit to add some.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedNodes) { node in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 12) {
                                if node.emoji != nil || node.imageData != nil {
                                    CustomIcon(emoji: node.emoji, imageData: node.imageData, size: AppConstants.IconSize.small)
                                }
                                Text(node.title)
                                Spacer()
                                if let d = node.durationMinutes {
                                    Text("\(d) min")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            if !node.notes.isEmpty {
                                Text(node.notes)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 36)
                            }
                        }
                    }
                }
            } header: {
                Text("Nodes")
            }
        }
        .navigationTitle(flow.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    if flow.emoji != nil || flow.imageData != nil {
                        CustomIcon(emoji: flow.emoji, imageData: flow.imageData, size: AppConstants.IconSize.small)
                    }
                    Text(flow.title)
                        .font(.headline)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            FlowFormView(existingFlow: flow)
        }
    }
}

