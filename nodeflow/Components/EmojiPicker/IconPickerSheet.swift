import SwiftUI
import PhotosUI

struct IconPickerSheet: View {
    @Binding var emoji: String
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    @State private var tab = 0
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $tab) {
                    Text("Emoji").tag(0)
                    Text("Photo").tag(1)
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top], 12)

                if tab == 0 {
                    EmojiGridView(currentEmoji: emoji) { picked in
                        emoji = picked; imageData = nil; dismiss()
                    }
                } else {
                    Spacer()
                    if let data = imageData, let ui = UIImage(data: data) {
                        Image(uiImage: ui)
                            .resizable().scaledToFill()
                            .frame(width: AppConstants.IconSize.preview, height: AppConstants.IconSize.preview)
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.sheetCornerRadius))
                            .padding(.bottom, 24)
                    }
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    .onChange(of: selectedPhoto) { _, item in
                        Task {
                            if let data = try? await item?.loadTransferable(type: Data.self) {
                                imageData = data; emoji = ""; dismiss()
                            }
                        }
                    }
                    Spacer()
                }
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                if !emoji.isEmpty || imageData != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Remove") { emoji = ""; imageData = nil; dismiss() }
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .presentationDetents([.large])
    }
}
