import Foundation
import CoreData
import CloudKit
import Observation
import os

/// Tracks whether iCloud sync is working, for the About page.
@Observable
final class SyncStatus {
    static let shared = SyncStatus()
    static let containerID = "iCloud.com.hu921.simpletasks"

    /// "iCloud" or "This device only".
    var storage = "Starting…"
    var account = "Checking…"
    var lastSync = "Not yet"
    /// The most recent error, in words, if any.
    var lastError: String?

    @ObservationIgnored private var observer: NSObjectProtocol?
    @ObservationIgnored private let log = Logger(subsystem: "com.hu921.simpletasks", category: "sync")

    /// Call before the data container is created, so the first sync is recorded.
    func start() {
        guard observer == nil else { return }
        observer = NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let event = note.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                as? NSPersistentCloudKitContainer.Event else { return }
            self?.record(event)
        }
        Task { await checkAccount() }
    }

    func usingCloud() {
        update { $0.storage = "iCloud" }
        log.notice("Store opened with iCloud sync")
    }

    func usingLocal(because error: Error) {
        let text = Self.describe(error)
        update {
            $0.storage = "This device only"
            $0.lastError = "Setup: \(text)"
        }
        log.error("iCloud store failed, using local store: \(text, privacy: .public)")
    }

    func checkAccount() async {
        let text: String
        do {
            switch try await CKContainer(identifier: Self.containerID).accountStatus() {
            case .available: text = "Signed in"
            case .noAccount: text = "Not signed in"
            case .restricted: text = "Restricted"
            case .couldNotDetermine: text = "Unknown"
            case .temporarilyUnavailable: text = "Temporarily unavailable"
            @unknown default: text = "Unknown"
            }
        } catch {
            text = "Error: \(Self.describe(error))"
        }
        log.notice("iCloud account: \(text, privacy: .public)")
        update { $0.account = text }
    }

    private func record(_ event: NSPersistentCloudKitContainer.Event) {
        guard let end = event.endDate else { return }
        let kind: String
        switch event.type {
        case .setup: kind = "Setup"
        case .import: kind = "Download"
        case .export: kind = "Upload"
        @unknown default: kind = "Sync"
        }
        if event.succeeded {
            let time = end.formatted(date: .omitted, time: .shortened)
            update {
                $0.lastSync = "\(kind) OK at \(time)"
                // A later success clears an earlier failure of the same kind.
                if $0.lastError?.hasPrefix("\(kind):") == true { $0.lastError = nil }
            }
        } else {
            let text = event.error.map(Self.describe) ?? "Unknown error"
            update { $0.lastError = "\(kind): \(text)" }
            log.error("\(kind, privacy: .public) failed: \(text, privacy: .public)")
        }
    }

    private func update(_ change: @escaping (SyncStatus) -> Void) {
        if Thread.isMainThread {
            change(self)
        } else {
            DispatchQueue.main.async { change(self) }
        }
    }

    private static func describe(_ error: Error) -> String {
        let ns = error as NSError
        var text = "\(ns.domain) \(ns.code): \(ns.localizedDescription)"
        if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? NSError {
            text += " (\(underlying.domain) \(underlying.code): \(underlying.localizedDescription))"
        }
        return text
    }
}
