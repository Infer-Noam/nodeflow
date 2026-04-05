
import SwiftUI
import SwiftData

struct FlowFormView: View {
    @State private var viewModel: FlowFormViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    enum Field { case title, flowNotes, nodeTitle, nodeNotes, nodeDuration }

    init(existingFlow: Flow? = nil) {
        _viewModel = State(initialValue: FlowFormViewModel(existingFlow: existingFlow))
    }

    var body: some View {
        NavigationStack {
            Form {
                flowInfoSection
                scheduleSection
                FlowNodesSection(viewModel: $viewModel, focusedField: $focusedField)
            }
            .navigationTitle(viewModel.isEditing ? "Edit Flow" : "New Flow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.trySave(context: modelContext, focusTitle: { focusedField = .title }) {
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
            Toggle("Set a time", isOn: $viewModel.hasScheduledTime)
            if viewModel.hasScheduledTime {
                DatePicker("Start time", selection: $viewModel.scheduledTime, displayedComponents: .hourAndMinute)
            }
            Toggle("Set duration", isOn: $viewModel.hasDuration)
            if viewModel.hasDuration {
                Stepper("\(viewModel.durationMinutes) min total", value: $viewModel.durationMinutes, in: 5...480, step: 5)
            }
            Toggle("Recurring", isOn: $viewModel.isRecurring)
            if viewModel.isRecurring {
                Picker("Frequency", selection: $viewModel.recurrenceFrequency) {
                    ForEach(RecurrenceFrequency.allCases, id: \.self) { freq in
                        Text(freq.rawValue).tag(freq)
                    }
                }
            }
        }
    }

}

#Preview {
    FlowFormView()
        .modelContainer(for: Flow.self, inMemory: true)
}

