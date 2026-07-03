public struct AppearanceRefreshPolicy: Equatable, Sendable {
    public static let interfaceThemeChangedNotificationName = "AppleInterfaceThemeChangedNotification"

    public init() {}

    public func shouldRefreshAppearance(forNotificationNamed notificationName: String) -> Bool {
        notificationName == Self.interfaceThemeChangedNotificationName
    }
}
