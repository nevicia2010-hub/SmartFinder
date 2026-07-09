import Foundation

public enum FileClipboardPolicy {
    public static let operationPasteboardType = "local.smartfinder.file-operation"
    public static let copyMarker = "copy"
    public static let moveMarker = "move"

    public static func operation(forMarker marker: String?) -> FileTransferOperation {
        marker == moveMarker ? .move : .copy
    }
}
