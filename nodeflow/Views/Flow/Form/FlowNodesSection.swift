import SwiftUI

struct FlowNodesSection: View {
    @Binding var viewModel: FlowFormViewModel

    @State private var editingNode: FlowFormViewModel.NodeDraft? = nil
    @State private var addingNode = false

    var body: some View {
        Section {
            if !viewModel.nodes.isEmpty {
                ForEach(viewModel.nodes) { draft in
                    let index = viewModel.nodes.firstIndex(where: { $0.id == draft.id }) ?? 0
                    Button { editingNode = draft } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 8) {
                                CustomIcon(emoji: draft.emoji.isEmpty ? nil : draft.emoji, imageData: draft.imageData, size: 32)
                                Text("\(index + 1). \(draft.title)")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if let d = draft.duration {
                                    Text("\(d) min")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            if !draft.notes.isEmpty {
                                Text(draft.notes)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 40)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { viewModel.nodes.remove(atOffsets: $0) }
                .onMove { viewModel.nodes.move(fromOffsets: $0, toOffset: $1) }
            }

            Button {
                addingNode = true
            } label: {
                Label("Add Node", systemImage: "plus.circle.fill")
            }
        } header: {
            HStack {
                Text("Nodes")
                Spacer()
                if !viewModel.nodes.isEmpty {
                    Text("Tap to edit · swipe to delete · drag to reorder")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .textCase(nil)
                }
            }
        }
        .sheet(item: $editingNode) { node in
            NodeEditSheet(title: "Edit Node", node: node) { updated in
                if let i = viewModel.nodes.firstIndex(where: { $0.id == updated.id }) {
                    viewModel.nodes[i] = updated
                }
            }
        }
        .sheet(isPresented: $addingNode) {
            NodeEditSheet(title: "New Node", node: FlowFormViewModel.NodeDraft(title: "", emoji: "", notes: "", duration: nil, imageData: nil)) { newNode in
                if !newNode.title.isEmpty {
                    viewModel.nodes.append(newNode)
                }
            }
        }
    }
}
