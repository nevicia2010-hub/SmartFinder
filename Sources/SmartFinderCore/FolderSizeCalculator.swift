import Foundation

public enum FolderSizeCalculationError: Error, Equatable {
    case cancelled
}

public final class FolderSizeCancellationToken: @unchecked Sendable {
    private let lock = NSLock()
    private var cancelled = false

    public init() {}

    public func cancel() {
        lock.lock()
        cancelled = true
        lock.unlock()
    }

    public var isCancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return cancelled
    }
}

public struct FolderSizeResult: Equatable, Sendable {
    public let byteSize: Int64
    public let fileCount: Int
    public let folderCount: Int

    public init(byteSize: Int64, fileCount: Int, folderCount: Int) {
        self.byteSize = byteSize
        self.fileCount = fileCount
        self.folderCount = folderCount
    }
}

public final class FolderSizeCalculator {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func calculateSize(
        of folderURL: URL,
        cancellationToken: FolderSizeCancellationToken = FolderSizeCancellationToken()
    ) throws -> FolderSizeResult {
        try checkCancellation(cancellationToken)

        guard let enumerator = fileManager.enumerator(
            at: folderURL,
            includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey, .fileSizeKey],
            options: []
        ) else {
            return FolderSizeResult(byteSize: 0, fileCount: 0, folderCount: 0)
        }

        var byteSize: Int64 = 0
        var fileCount = 0
        var folderCount = 0

        for case let itemURL as URL in enumerator {
            try checkCancellation(cancellationToken)
            let values = try? itemURL.resourceValues(forKeys: [.isRegularFileKey, .isDirectoryKey, .fileSizeKey])
            if values?.isDirectory == true {
                folderCount += 1
            } else if values?.isRegularFile == true {
                fileCount += 1
                byteSize += Int64(values?.fileSize ?? 0)
            }
        }

        return FolderSizeResult(byteSize: byteSize, fileCount: fileCount, folderCount: folderCount)
    }

    private func checkCancellation(_ cancellationToken: FolderSizeCancellationToken) throws {
        if cancellationToken.isCancelled {
            throw FolderSizeCalculationError.cancelled
        }
    }
}
