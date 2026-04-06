
import SwiftUI
import SwiftData

struct FlowFormView: View {
    @State private var viewModel: FlowFormViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(CalendarSyncService.self) private var calendarSync
    @FocusState private var focusedField: Field?
    @State private var nodeSheetMode: NodeSheetMode? = nil

    enum Field { case title, flowNotes }

    init(existingFlow: Flow? = nil) {
        _viewModel = State(initialValue: FlowFormViewModel(existingFlow: existingFlow))
    }

    var body: some View {
        NavigationStack {
            Form {
                flowInfoSection
                scheduleSection
                FlowCalendarSection(viewModel: $viewModel, calendarSync: calendarSync)
                FlowNodesSection(viewModel: $viewModel, sheetMode: $nodeSheetMode)
            }
            .navigationTitle(viewModel.isEditing ? "Edit Flow" : "New Flow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.trySave(
                            context: modelContext,
                            calendarSync: calendarSync,
                            focusTitle: { focusedField = .title }
                        ) {
                            dismiss()
                        }
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Done") { focusedField = nil }
                    Spacer()
                }
            }
            .onAppear { viewModel.loadExisting() }
            .sheet(item: $nodeSheetMode) { mode in
                switch mode {
                case .add:
                    NodeEditSheet(title: "New Node", node: FlowFormViewModel.NodeDraft(title: "", emoji: "", notes: "", duration: nil, imageData: nil)) { newNode in
                        if !newNode.title.isEmpty {
                            viewModel.nodes.append(newNode)
                        }
                    }
                case .edit(let node):
                    NodeEditSheet(title: "Edit Node", node: node) { updated in
                        if let i = viewModel.nodes.firstIndex(where: { $0.id == updated.id }) {
                            viewModel.nodes[i] = updated
                        }
                    }
                }
            }
        }
    }

    private var flowInfoSection: some View {
        Section {
            HStack(spacing: 12) {
                IconPickerButton(emoji: $viewModel.flowEmoji, imageData: $viewModel.flowImageData)
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Title, e.g. Morning Routine", text: $viewModel.title)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .flowNotes }
                        .onChange(of: viewModel.title) { viewModel.titleError = false }
                    if viewModel.titleError {
                        Text("Title is required")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                .focused($focusedField, equals: .flowNotes)
                .lineLimit(2...4)
        } header: {
            Text("Flow")
        }
    }

    private var scheduleSection: some View {
        Section("Schedule") {
            Toggle("Set duration", isOn: $viewModel.hasDuration)
            if viewModel.hasDuration {
                Stepper("\(viewModel.durationMinutes) min total", value: $viewModel.durationMinutes, in: 5...480, step: 5)
            }
        }
    }

}

#Preview {
    FlowFormView()
        .modelContainer(for: Flow.self, inMemory: true)
        .environment(CalendarSyncService(googleClientID: GoogleOAuthConfig.clientID))
}

