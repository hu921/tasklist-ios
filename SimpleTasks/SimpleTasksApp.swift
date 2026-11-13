import SwiftUI
import SwiftData

@main
struct SimpleTasksApp: App {
    init() {
        AppFont.register()
        // Finishes any tip paid while the app was closed.
        Task { await TipJar.shared.start() }
    }

    let container: ModelContainer = {
        let schema = Schema([TaskItem.self])
        AppLog.logLaunch()
        SyncStatus.shared.start()
        do {
            // Syncs through the user's iCloud account. No sign-in in the app.
            let cloud = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .private(SyncStatus.containerID)
            )
            let container = try ModelContainer(for: schema, configurations: cloud)
            SyncStatus.shared.usingCloud()
            return container
        } catch {
            // Falls back to on-device storage if iCloud is not available.
            SyncStatus.shared.usingLocal(because: error)
            let local = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
            return try! ModelContainer(for: schema, configurations: local)
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
        #if os(macOS)
        .defaultSize(width: 420, height: 640)
        #endif

        #if os(macOS)
        Window(Text(L("Settings")), id: Self.settingsWindowID) {
            AboutView()
        }
        .defaultSize(width: 440, height: 680)
        #endif
    }

    static let settingsWindowID = "settings"
}
