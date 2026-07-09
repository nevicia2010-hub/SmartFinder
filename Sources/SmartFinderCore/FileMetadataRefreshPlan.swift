import Foundation

public enum FileMetadataRefreshPlan {
    public static func affectedDirectoryURLs(changedItemURLs: [URL]) -> [URL] {
        FileTransferPlan.uniqueSourceURLs(changedItemURLs)
            .map { $0.deletingLastPathComponent().standardizedFileURL }
            .appendingUnique()
    }

    public static func refreshScope(
        isColumnView: Bool,
        currentFolderURL: URL?,
        affectedDirectoryURLs: [URL]
    ) -> FileTransferRefreshScope {
        FileTransferPlan.refreshScope(
            isColumnView: isColumnView,
            currentFolderURL: currentFolderURL,
            affectedDirectoryURLs: affectedDirectoryURLs
        )
    }
}

private extension Array where Element == URL {
    func appendingUnique() -> [URL] {
        var result: [URL] = []
        for url in self where !result.contains(url) {
            result.append(url)
        }
        return result
    }
}
