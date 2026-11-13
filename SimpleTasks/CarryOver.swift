import Foundation
import SwiftData

/// Moves unfinished tasks from past days, weeks, or months onto the current page.
/// Finished tasks stay on the page where they were checked off.
enum CarryOver {
    @MainActor
    static func run(in context: ModelContext, now: Date = .now) {
        let started = Date.now
        let descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate { $0.isDone == false })
        guard let openTasks = try? context.fetch(descriptor) else { return }

        var removed = 0
        var carried = 0
        for task in openTasks where task.isBlank {
            // A task whose text was erased is removed.
            context.delete(task)
            removed += 1
        }
        for task in openTasks where !task.isBlank {
            let current = task.period.start(of: now)
            // Compare pages, so a task saved in another time zone is not moved by mistake.
            if task.period.page(of: task.periodStart) < current {
                task.periodStart = current
                carried += 1
            }
        }
        if removed + carried > 0 { try? context.save() }
        AppLog.log("carry-over", "\(openTasks.count) open, \(carried) carried, \(removed) empty removed, \(AppLog.ms(since: started))")
    }
}
