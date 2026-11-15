import Foundation

/// Sharing a task with a friend who also has Simple Todo.
/// The friend gets their own copy: each person checks it off separately.
///
/// The link looks like `simpletodo://add?title=Buy%20milk&list=daily`.
/// Opening it shows "Add this task?" in the app. Nothing is sent to a server.
struct SharedTask: Identifiable, Equatable {
    let title: String
    let period: Period
    var id: String { "\(period.rawValue)-\(title)" }

    static let scheme = "simpletodo"
    static let maxLength = 500

    var url: URL {
        var parts = URLComponents()
        parts.scheme = Self.scheme
        parts.host = "add"
        parts.queryItems = [
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "list", value: period.rawValue),
        ]
        return parts.url!
    }

    /// The text that goes into iMessage with the link.
    var message: String {
        L("Task for you: “%@”", title) + "\n" + L("Tap to add it in Simple Todo:") + " " + url.absoluteString
    }

    init(title: String, period: Period) {
        self.title = String(title.prefix(Self.maxLength))
        self.period = period
    }

    /// Reads a shared link. Returns nil for anything else.
    init?(url: URL) {
        guard url.scheme?.lowercased() == Self.scheme, url.host?.lowercased() == "add",
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let title = items.first(where: { $0.name == "title" })?.value?
                .trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty
        else { return nil }
        let list = items.first(where: { $0.name == "list" })?.value ?? ""
        self.init(title: title.replacingOccurrences(of: "\n", with: " "), period: Period(rawValue: list) ?? .daily)
    }
}
