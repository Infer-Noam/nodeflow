import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Flow.title) private var flows: [Flow]
    @State private var showingNewFlow = false

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
                            modelContext.delete(flow)
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
}
