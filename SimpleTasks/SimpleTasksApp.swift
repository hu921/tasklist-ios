import SwiftUI
import SwiftData

@main
struct SimpleTasksApp: App {
    let container: ModelContainer = {
        let schema = Schema([TaskItem.self])
        do {
            // Syncs through the user's iCloud account. No sign-in in the app.
            let cloud = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
            return try ModelContainer(for: schema, configurations: cloud)
        } catch {
            // Falls back to on-device storage if iCloud is not available.
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
    }
}
