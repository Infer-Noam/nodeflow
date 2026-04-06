import SwiftUI

struct FlowRunControls: View {
    let currentIndex: Int
    let totalCount: Int
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.title3.weight(.semibold))
                    .frame(width: 56, height: 56)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Circle())
            }
            .disabled(currentIndex == 0)
            .opacity(currentIndex == 0 ? 0.35 : 1)

            Button(action: onNext) {
                HStack(spacing: 8) {
                    Text(currentIndex == totalCount - 1 ? "Finish" : "Next")
                        .font(.headline)
                    Image(systemName: currentIndex == totalCount - 1 ? "checkmark" : "arrow.right")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Capsule()
                        .fill(currentIndex == totalCount - 1 ? Color.green : Color.accentColor)
                )
            }
        }
    }
}
