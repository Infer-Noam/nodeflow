import SwiftUI

struct IconPickerButton: View {
    @Binding var emoji: String
    @Binding var imageData: Data?
    var size: CGFloat = 44
    @State private var showingPicker = false

    var body: some View {
        Button { showingPicker = true } label: {
            CustomIcon(emoji: emoji.isEmpty ? nil : emoji, imageData: imageData, size: size)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingPicker) {
            IconPickerSheet(emoji: $emoji, imageData: $imageData)
        }
    }
}
