import Foundation

/// Shown on the About page. Rows with `nil` are hidden.
enum AppInfo {
    static let developerName: String? = nil
    static let website: URL? = nil
    /// Shown as "Contact" on the About page.
    static let supportEmail = "support.simpletodo@gmail.com"

    /// e.g. "Simple Todo 1.0 (12), iOS Version 18.1". No task data.
    static var deviceInfo: String {
        #if os(macOS)
        let platform = "macOS"
        #else
        let platform = "iOS"
        #endif
        return "Simple Todo \(version), \(platform) \(ProcessInfo.processInfo.operatingSystemVersionString)"
    }

    /// Opens a new email to support with the app version filled in.
    static var contactMailURL: URL? {
        var parts = URLComponents()
        parts.scheme = "mailto"
        parts.path = supportEmail
        parts.queryItems = [
            URLQueryItem(name: "subject", value: "Simple Todo"),
            URLQueryItem(name: "body", value: "\n\n\n---\n\(deviceInfo)"),
        ]
        return parts.url
    }

    /// The year shown in the About copyright line.
    static let copyrightYear = "2026"

    static var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }
}
