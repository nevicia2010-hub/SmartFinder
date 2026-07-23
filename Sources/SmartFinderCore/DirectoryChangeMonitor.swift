import Darwin
import Dispatch
import Foundation

public final class DirectoryChangeMonitor: @unchecked Sendable {
    private let debounceInterval: TimeInterval
    private let queue: DispatchQueue
    private var source: DispatchSourceFileSystemObject?
    private var pendingChange: DispatchWorkItem?
    private var changeHandler: (@Sendable () -> Void)?
    private var monitoredURL: URL?

    public init(debounceInterval: TimeInterval = 0.35) {
        self.debounceInterval = debounceInterval
        queue = DispatchQueue(
            label: "com.smartfinder.directory-change-monitor.\(UUID().uuidString)",
            qos: .utility
        )
    }

    deinit {
        stopMonitoring()
    }

    @discardableResult
    public func startMonitoring(
        directoryURL: URL,
        onChange: @escaping @Sendable () -> Void
    ) -> Bool {
        let standardizedURL = directoryURL.standardizedFileURL
        return queue.sync {
            if monitoredURL == standardizedURL, source != nil {
                changeHandler = onChange
                return true
            }

            stopMonitoringOnQueue()
            let descriptor = open(standardizedURL.path, O_EVTONLY)
            guard descriptor >= 0 else {
                return false
            }

            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: descriptor,
                eventMask: [.write, .extend, .attrib, .link, .rename, .delete, .revoke],
                queue: queue
            )
            source.setEventHandler { [weak self] in
                self?.scheduleChangeOnQueue()
            }
            source.setCancelHandler {
                close(descriptor)
            }

            self.source = source
            changeHandler = onChange
            monitoredURL = standardizedURL
            source.resume()
            return true
        }
    }

    public func stopMonitoring() {
        queue.sync {
            stopMonitoringOnQueue()
        }
    }

    private func scheduleChangeOnQueue() {
        pendingChange?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self, let changeHandler = self.changeHandler else {
                return
            }
            self.pendingChange = nil
            changeHandler()
        }
        pendingChange = workItem
        queue.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
    }

    private func stopMonitoringOnQueue() {
        pendingChange?.cancel()
        pendingChange = nil
        changeHandler = nil
        monitoredURL = nil
        source?.cancel()
        source = nil
    }
}
