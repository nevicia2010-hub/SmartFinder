import Foundation

public enum DualPanePolicy {
    public static func shouldLoadSecondaryPane(
        wasVisible: Bool,
        isVisible: Bool,
        hasLoadedSecondaryPane: Bool
    ) -> Bool {
        !wasVisible && isVisible && !hasLoadedSecondaryPane
    }
}
