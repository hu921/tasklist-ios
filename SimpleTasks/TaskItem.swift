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

    init(title: String, period: Period, periodStart: Date) {
        self.title = title
        self.periodRaw = period.rawValue
        self.periodStart = periodStart
        self.createdAt = .now
    }

    var period: Period { Period(rawValue: periodRaw) ?? .daily }
}
