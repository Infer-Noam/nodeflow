import SwiftUI

struct EmojiGridView: View {
    let currentEmoji: String
    let onPick: (String) -> Void
    @State private var search = ""
    @State private var selectedCat = 0

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppConstants.EmojiGrid.itemSpacing), count: AppConstants.EmojiGrid.columns)

    private var displayEmoji: [String] {
        search.isEmpty ? EmojiData.categories[selectedCat].emoji
                       : EmojiData.all.filter { $0.contains(search) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search emoji", text: $search).autocorrectionDisabled()
                if !search.isEmpty {
                    Button { search = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)

            if search.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(EmojiData.categories.indices, id: \.self) { i in
                            Button { selectedCat = i } label: {
                                Text(EmojiData.categories[i].emoji.first ?? "")
                                    .font(.title3)
                                    .frame(width: AppConstants.EmojiGrid.categoryTabWidth, height: AppConstants.EmojiGrid.categoryTabHeight)
                                    .background(selectedCat == i ? Color.accentColor.opacity(0.2) : Color.clear,
                                                in: RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(displayEmoji, id: \.self) { e in
                        Button { onPick(e) } label: {
                            Text(e)
                                .font(.system(size: 30))
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .background(currentEmoji == e ? Color.accentColor.opacity(0.2) : Color.clear,
                                            in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
    }
}
