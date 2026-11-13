import Foundation
import StoreKit
import os

/// A small on-device log of what the app does, for testing.
///
/// It records actions, sync results, timing, and errors. It never records task text.
/// The file stays on the device. In test builds (Xcode and TestFlight) the About
/// page has a "Share log" button so the tester can send it. App Store users never
/// see the button, and nothing is sent anywhere.
enum AppLog {
    private static let queue = DispatchQueue(label: "com.hu921.simpletasks.applog")
    private static let logger = Logger(subsystem: "com.hu921.simpletasks", category: "app")
    /// When the file grows past this size, the older half is dropped.
    private static let maxBytes: UInt64 = 256 * 1024

    static var fileURL: URL {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return folder.appendingPathComponent("SimpleTodo-log.txt")
    }

    /// Adds one line, e.g. `AppLog.log("task added", "daily")`.
    static func log(_ event: String, _ detail: String = "") {
        let text = detail.isEmpty ? event : "\(event): \(detail)"
        logger.notice("\(text, privacy: .public)")
        let line = "\(Date.now.ISO8601Format()) \(text)\n"
        queue.async { append(line) }
    }

    /// Logs an error with its domain and code.
    static func error(_ event: String, _ error: Error) {
        let ns = error as NSError
        log(event, "\(ns.domain) \(ns.code) \(ns.localizedDescription)")
    }

    /// Milliseconds since `start`, for timing lines.
    static func ms(since start: Date) -> String {
        "\(Int(Date.now.timeIntervalSince(start) * 1000)) ms"
    }

    /// First line of each launch: app version and device.
    static func logLaunch() {
        #if os(macOS)
        let platform = "macOS"
        #else
        let platform = "iOS"
        #endif
        log("app launched", "version \(AppInfo.version), \(platform) \(ProcessInfo.processInfo.operatingSystemVersionString)")
    }

    /// True in Xcode and TestFlight builds, false in the App Store version.
    static func isTestBuild() async -> Bool {
        #if DEBUG
        return true
        #else
        guard let result = try? await AppTransaction.shared else { return false }
        switch result {
        case .verified(let transaction), .unverified(let transaction, _):
            return transaction.environment != .production
        }
        #endif
    }

    private static func append(_ line: String) {
        guard let data = line.data(using: .utf8) else { return }
        let url = fileURL
        let files = FileManager.default
        if !files.fileExists(atPath: url.path) {
            try? files.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            files.createFile(atPath: url.path, contents: nil)
        }
        guard let handle = try? FileHandle(forUpdating: url) else { return }
        defer { try? handle.close() }
        let size = (try? handle.seekToEnd()) ?? 0
        if size > maxBytes {
            // Keep the newer half.
            try? handle.seek(toOffset: size / 2)
            let newer = (try? handle.readToEnd()) ?? Data()
            try? handle.truncate(atOffset: 0)
            try? handle.write(contentsOf: newer)
        }
        try? handle.write(contentsOf: data)
    }
}
