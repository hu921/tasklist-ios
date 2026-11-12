import Foundation

/// The three pages of the booklet: one per day, week, or month.
enum Period: String, CaseIterable, Identifiable {
    case daily, weekly, monthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: "Daily"
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        }
    }

    var currentLabel: String {
        switch self {
        case .daily: "Today"
        case .weekly: "This Week"
        case .monthly: "This Month"
        }
    }

    private var component: Calendar.Component {
        switch self {
        case .daily: .day
        case .weekly: .weekOfYear
        case .monthly: .month
        }
    }

    /// Start of the day, week, or month that contains `date`.
    func start(of date: Date, calendar: Calendar = .current) -> Date {
        switch self {
        case .daily:
            return calendar.startOfDay(for: date)
        case .weekly, .monthly:
            return calendar.dateInterval(of: component, for: date)?.start
                ?? calendar.startOfDay(for: date)
        }
    }

    /// Start of the page `value` pages away from `start`.
    func shift(_ start: Date, by value: Int, calendar: Calendar = .current) -> Date {
        let moved = calendar.date(byAdding: component, value: value, to: start) ?? start
        return self.start(of: moved, calendar: calendar)
    }

    /// Page heading, e.g. "Wednesday, November 11", "Week of Nov 9", "November 2026".
    func label(for start: Date) -> String {
        switch self {
        case .daily:
            return start.formatted(.dateTime.weekday(.wide).month(.wide).day())
        case .weekly:
            return "Week of " + start.formatted(.dateTime.month(.abbreviated).day())
        case .monthly:
            return start.formatted(.dateTime.month(.wide).year())
        }
    }
}
