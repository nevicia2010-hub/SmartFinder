import Foundation

public enum FileCreationTargetPolicy {
    public static func targetDirectory(currentFolderURL: URL?, contextualFolderURL: URL?) -> URL? {
        contextualFolderURL ?? currentFolderURL
    }
}
