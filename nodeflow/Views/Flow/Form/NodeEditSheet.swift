import SwiftUI

struct NodeEditSheet: View {
    let title: String
    let node: FlowFormViewModel.NodeDraft
    let onSave: (FlowFormViewModel.NodeDraft) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var nodeTitle: String
    @State private var emoji: String
    @State private var notes: String
    @State private var durationText: String
    @State private var imageData: Data?

    init(title: String, node: FlowFormViewModel.NodeDraft, onSave: @escaping (FlowFormViewModel.NodeDraft) -> Void) {
        self.title = title
        self.node = node
        self.onSave = onSave
        _nodeTitle = State(initialValue: node.title)
        _emoji = State(initialValue: node.emoji)
        _notes = State(initialValue: node.notes)
        _durationText = State(initialValue: node.duration.map { String($0) } ?? "")
        _imageData = State(initialValue: node.imageData)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        IconPickerButton(emoji: $emoji, imageData: $imageData)
                        TextField("Node title", text: $nodeTitle)
                    }
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                }
                Section("Duration") {
                    HStack {
                        TextField("Minutes", text: $durationText)
                            .keyboardType(.numberPad)
                        Text("min").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        var updated = node
                        updated.title = nodeTitle.trimmingCharacters(in: .whitespaces)
                        updated.emoji = emoji
                        updated.notes = notes
                        updated.duration = Int(durationText)
                        updated.imageData = imageData
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(nodeTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
