import Foundation

public struct DefaultApplicationChangePolicy {
    public init() {}

    public func canChangeDefaultApplication(
        contentTypeIdentifier: String?,
        applicationBundleIdentifier: String?
    ) -> Bool {
        guard let contentTypeIdentifier,
              let applicationBundleIdentifier else {
            return false
        }

        return !contentTypeIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !applicationBundleIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
