import CoreGraphics


enum AppConstants {

    enum IconSize {
        /// Navigation bar and node row icons
        static let small: CGFloat = 28
        /// Flow card icons
        static let medium: CGFloat = 40
        /// Form picker buttons (default CustomIcon size)
        static let large: CGFloat = 44
        /// Image preview inside the icon picker sheet
        static let preview: CGFloat = 110
    }

    enum Layout {
        static let padding: CGFloat = 16
        static let cardSpacing: CGFloat = 10
        static let sectionSpacing: CGFloat = 20
        static let sheetCornerRadius: CGFloat = 22
    }

    enum EmojiGrid {
        static let columns: Int = 9
        static let itemSpacing: CGFloat = 4
        static let categoryTabWidth: CGFloat = 40
        static let categoryTabHeight: CGFloat = 36
    }
}
