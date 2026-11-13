import Foundation
import SwiftData

/// One line in the booklet.
/// Every property has a default value so the model works with iCloud (CloudKit) sync.
@Model
final class TaskItem {
    var title: String = ""
    var periodRaw: String = Period.daily.rawValue
    /// Start of the day, week, or month this task belongs to.
    var periodStart: Date = Date.now
    var isDone: Bool = false
    /// Red flag: must be done today. Daily tasks only.
    var isUrgent: Bool = false
    var completedAt: Date?
    var createdAt: Date = Date.now
    /// Set when the task is moved to another list, so it goes to the bottom there.
    var movedAt: Date?

    init(title: String, period: Period, periodStart: Date) {
        self.title = title
        self.periodRaw = period.rawValue
        self.periodStart = periodStart
        self.createdAt = .now
    }

    var period: Period { Period(rawValue: periodRaw) ?? .daily }

    /// True when the task has no text.
    var isBlank: Bool { title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    /// Position in its list: the order tasks were added or moved in.
    var listOrder: Date { movedAt ?? createdAt }

    /// Moves the task to the Daily, Weekly, or Monthly list.
    /// It lands on today's page if today is within the task's current page,
    /// otherwise on the page that contains the start of its current page.
    func move(to target: Period, now: Date = .now) {
        guard target != period else { return }
        AppLog.log("task moved", "\(period.rawValue) to \(target.rawValue)")
        let end = period.shift(periodStart, by: 1)
        let anchor = (periodStart..<end).contains(now) ? now : periodStart
        periodRaw = target.rawValue
        periodStart = target.start(of: anchor)
        movedAt = now
        if target != .daily { isUrgent = false }
    }
}
