import SwiftUI

struct CustomIcon: View {
    var emoji: String?
    var imageData: Data?
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.system(size: size * 0.55))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: size * 0.38))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: size, height: size)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
    }
}
