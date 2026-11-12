import Foundation
import SwiftData

/// Moves unfinished tasks from past days, weeks, or months onto the current page.
/// Finished tasks stay on the page where they were checked off.
enum CarryOver {
    @MainActor
    static func run(in context: ModelContext, now: Date = .now) {
        let descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate { $0.isDone == false })
        guard let openTasks = try? context.fetch(descriptor) else { return }

        var changed = false
        for task in openTasks {
            let current = task.period.start(of: now)
            if task.periodStart < current {
                task.periodStart = current
                changed = true
            }
        }
        if changed { try? context.save() }
    }
}
