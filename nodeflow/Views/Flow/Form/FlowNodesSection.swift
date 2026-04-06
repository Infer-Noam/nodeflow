import SwiftUI

struct FlowNodesSection: View {
    @Binding var viewModel: FlowFormViewModel
    var focusedField: FocusState<FlowFormView.Field?>.Binding

    var body: some View {
        Section {
            if !viewModel.nodes.isEmpty {
                ForEach(viewModel.nodes) { draft in
                    let index = viewModel.nodes.firstIndex(where: { $0.id == draft.id }) ?? 0
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            CustomIcon(emoji: draft.emoji.isEmpty ? nil : draft.emoji, imageData: draft.imageData, size: 32)
                            Text("\(index + 1). \(draft.title)")
                                .font(.body)
                            Spacer()
                            if let d = draft.duration {
                                Text("\(d) min")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        if !draft.notes.isEmpty {
                            Text(draft.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { viewModel.nodes.remove(atOffsets: $0) }
                .onMove { viewModel.nodes.move(fromOffsets: $0, toOffset: $1) }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    IconPickerButton(emoji: $viewModel.newNodeEmoji, imageData: $viewModel.newNodeImageData)
                    TextField("New node title", text: $viewModel.newNodeTitle)
                        .focused(focusedField, equals: .nodeTitle)
                        .submitLabel(.next)
                        .onSubmit { focusedField.wrappedValue = .nodeNotes }
                        .onChange(of: viewModel.newNodeTitle) { viewModel.nodeTitleError = false }
                    TextField("min", text: $viewModel.newNodeDuration)
                        .focused(focusedField, equals: .nodeDuration)
                        .keyboardType(.numberPad)
                        .frame(width: 40)
                    Button(action: viewModel.commitPendingNode) {
                        Image(systemName: "return.left")
                    }
                    .disabled(viewModel.newNodeTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                if viewModel.nodeTitleError {
                    Text("Enter a node title first")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                TextField("Notes (optional)", text: $viewModel.newNodeNotes, axis: .vertical)
                    .focused(focusedField, equals: .nodeNotes)
                    .lineLimit(1...3)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        } header: {
            HStack {
                Text("Nodes")
                Spacer()
                if !viewModel.nodes.isEmpty {
                    Text("Swipe to delete · drag to reorder")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .textCase(nil)
                }
            }
        } footer: {
            if viewModel.nodes.isEmpty && viewModel.newNodeTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                Text("Type a node title above to get started.")
                    .font(.caption)
            }
        }
    }
}
