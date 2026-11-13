import Foundation

/// The three pages of the booklet: one per day, week, or month.
enum Period: String, CaseIterable, Identifiable {
    case daily, weekly, monthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: L("Daily")
        case .weekly: L("Weekly")
        case .monthly: L("Monthly")
        }
    }

    var currentLabel: String {
        switch self {
        case .daily: L("Today")
        case .weekly: L("This Week")
        case .monthly: L("This Month")
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

    /// The page a saved task belongs to, in the device's current time zone.
    /// A task saved in another time zone (travel, or another device) has a
    /// start that is a few hours off the local midnight; this rounds it to
    /// the page it was meant for.
    func page(of savedStart: Date, calendar: Calendar = .current) -> Date {
        start(of: savedStart.addingTimeInterval(12 * 3600), calendar: calendar)
    }

    /// Start of the page `value` pages away from `start`.
    func shift(_ start: Date, by value: Int, calendar: Calendar = .current) -> Date {
        let moved = calendar.date(byAdding: component, value: value, to: start) ?? start
        return self.start(of: moved, calendar: calendar)
    }

    /// Page heading, e.g. "Wednesday, November 11", "Week of Nov 9", "November 2026".
    func label(for start: Date) -> String {
        let locale = AppSettings.shared.locale
        switch self {
        case .daily:
            return start.formatted(.dateTime.weekday(.wide).month(.wide).day().locale(locale))
        case .weekly:
            return L("Week of %@", start.formatted(.dateTime.month(.abbreviated).day().locale(locale)))
        case .monthly:
            return start.formatted(.dateTime.month(.wide).year().locale(locale))
        }
    }
}
