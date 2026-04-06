import SwiftUI

struct FlowCalendarSection: View {
    @Binding var viewModel: FlowFormViewModel
    var calendarSync: CalendarSyncService

    @State private var signInError: String? = nil

    var body: some View {
        Section("Calendar Sync") {
            Picker("Sync with", selection: $viewModel.calendarProvider) {
                ForEach(CalendarProvider.allCases, id: \.self) { provider in
                    Text(provider.rawValue).tag(provider)
                }
            }
            .onChange(of: viewModel.calendarProvider) { old, new in
                if new == .google && !calendarSync.isGoogleSignedIn {
                    viewModel.calendarProvider = old
                    Task {
                        do {
                            try await calendarSync.googleAuth.signIn()
                            viewModel.calendarProvider = .google
                        } catch {
                            signInError = error.localizedDescription
                        }
                    }
                }
            }

            if viewModel.calendarProvider != .none {
                Toggle("Set a date & time", isOn: $viewModel.hasScheduledTime)
                if viewModel.hasScheduledTime {
                    DatePicker("Start", selection: $viewModel.scheduledTime, displayedComponents: [.date, .hourAndMinute])
                }
                Toggle("Recurring", isOn: $viewModel.isRecurring)
                if viewModel.isRecurring {
                    Picker("Frequency", selection: $viewModel.recurrenceFrequency) {
                        ForEach(RecurrenceFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                }
                Toggle("Add reminder", isOn: $viewModel.hasNotification)
                    .onChange(of: viewModel.hasNotification) {
                        if !viewModel.hasNotification { viewModel.notificationMinutesBefore = 0 }
                    }
                if viewModel.hasNotification {
                    Picker("Remind me", selection: $viewModel.notificationMinutesBefore) {
                        Text("At start time").tag(0)
                        Text("5 min before").tag(5)
                        Text("10 min before").tag(10)
                        Text("15 min before").tag(15)
                        Text("30 min before").tag(30)
                        Text("1 hour before").tag(60)
                    }
                }
            }
        }
        .alert("Sign-in failed", isPresented: Binding(
            get: { signInError != nil },
            set: { if !$0 { signInError = nil } }
        )) {
            Button("OK", role: .cancel) { signInError = nil }
        } message: {
            Text(signInError ?? "")
        }
    }
}
