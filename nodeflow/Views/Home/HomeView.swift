import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CalendarSyncService.self) private var calendarSync
    @Query(sort: \Flow.title) private var flows: [Flow]
    @State private var showingNewFlow = false
    @State private var deepLinkedFlow: Flow? = nil

    var body: some View {
        NavigationStack {
            Group {
                if flows.isEmpty {
                    emptyState
                } else {
                    flowList
                }
            }
            .navigationTitle("Flows")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingNewFlow = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewFlow) {
                FlowFormView()
            }
            .navigationDestination(item: $deepLinkedFlow) { flow in
                FlowDetailView(flow: flow)
            }
            .onOpenURL { url in
                guard url.scheme == "nodeflow",
                      url.host == "flow",
                      let id = url.pathComponents.dropFirst().first
                else { return }
                deepLinkedFlow = flows.first { $0.deepLinkID == id }
            }
        }
    }

    private var flowList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(flows) { flow in
                    NavigationLink(destination: FlowDetailView(flow: flow)) {
                        FlowCard(flow: flow)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            Task {
                                await calendarSync.remove(flow: flow)
                                modelContext.delete(flow)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("No Flows Yet")
                .font(.title2.bold())
            Text("Tap + to create your first flow,\nlike a Morning Routine.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Create Flow") { showingNewFlow = true }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Flow.self, inMemory: true)
        .environment(CalendarSyncService(googleClientID: GoogleOAuthConfig.clientID))
}
