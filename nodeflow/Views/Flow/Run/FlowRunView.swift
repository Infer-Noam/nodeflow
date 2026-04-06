import SwiftUI
import Combine

struct FlowRunView: View {
    let flow: Flow
    @Environment(\.dismiss) private var dismiss

    private var nodes: [FlowNode] {
        flow.nodes.sorted { $0.order < $1.order }
    }

    @State private var currentIndex: Int = 0
    @State private var secondsElapsed: Int = 0
    @State private var timerActive = false
    @State private var isComplete = false
    @State private var showingExitConfirm = false
    @State private var nodeOffset: CGFloat = 0
    @State private var nodeOpacity: Double = 1

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var currentNode: FlowNode? {
        guard nodes.indices.contains(currentIndex) else { return nil }
        return nodes[currentIndex]
    }

    private var totalDuration: Int? {
        let durations = nodes.compactMap(\.durationMinutes)
        return durations.count == nodes.count ? durations.reduce(0, +) : nil
    }

    private var progress: Double {
        guard !nodes.isEmpty else { return 1 }
        return Double(currentIndex) / Double(nodes.count)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.15), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            if isComplete {
                FlowRunCompletion(
                    flow: flow,
                    nodeCount: nodes.count,
                    secondsElapsed: secondsElapsed,
                    totalDuration: totalDuration,
                    onDone: { dismiss() }
                )
            } else {
                mainContent
            }
        }
        .onReceive(timer) { _ in
            guard timerActive else { return }
            secondsElapsed += 1
        }
        .onAppear { timerActive = true }
        .onDisappear { timerActive = false }
        .interactiveDismissDisabled(!isComplete)
        .confirmationDialog("Quit this run?", isPresented: $showingExitConfirm, titleVisibility: .visible) {
            Button("Quit", role: .destructive) { dismiss() }
            Button("Keep going", role: .cancel) {}
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            HStack {
                Button { showingExitConfirm = true } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .symbolRenderingMode(.hierarchical)
                }
                Spacer()
                Text("\(currentIndex + 1) of \(nodes.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "xmark.circle.fill").font(.title2).hidden()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5)).frame(height: 4)
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.spring(response: 0.5), value: progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 24)
            .padding(.top, 12)

            Spacer()

            if let node = currentNode {
                NodeRunCard(node: node, secondsElapsed: secondsElapsed)
                    .offset(x: nodeOffset)
                    .opacity(nodeOpacity)
                    .padding(.horizontal, 24)
            }

            Spacer()

            FlowRunControls(
                currentIndex: currentIndex,
                totalCount: nodes.count,
                onBack: {
                    guard currentIndex > 0 else { return }
                    transition(to: currentIndex - 1, direction: -1)
                },
                onNext: {
                    if currentIndex == nodes.count - 1 {
                        withAnimation(.spring(response: 0.5)) { isComplete = true }
                        timerActive = false
                    } else {
                        transition(to: currentIndex + 1, direction: 1)
                    }
                }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func transition(to index: Int, direction: CGFloat) {
        withAnimation(.easeIn(duration: 0.15)) {
            nodeOffset = -80 * direction
            nodeOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentIndex = index
            secondsElapsed = 0
            nodeOffset = 80 * direction
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                nodeOffset = 0
                nodeOpacity = 1
            }
        }
    }
}

