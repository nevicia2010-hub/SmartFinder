import Foundation

public enum IconLabelLayoutPolicy {
    public static let maximumTitleLineCount = 2

    public static func titleFontSize(forIconSize iconSize: Double) -> Double {
        switch iconSize {
        case ..<112:
            return 12
        case ..<156:
            return 13
        default:
            return 14
        }
    }

    public static func itemWidth(forIconSize iconSize: Double) -> Double {
        max(116, iconSize + 44)
    }

    public static func itemHeight(forIconSize iconSize: Double) -> Double {
        iconSize + 88
    }
}
