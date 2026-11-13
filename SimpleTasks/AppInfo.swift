import Foundation

/// Shown on the About page. Rows with `nil` are hidden.
enum AppInfo {
    static let developerName: String? = nil
    static let email: String? = nil
    static let website: URL? = nil
    /// Where "Send a wish" emails go. Always shown.
    static let supportEmail = "support.simpletodo@gmail.com"

    /// Opens a new email to support with the app version filled in. No task data.
    static var wishMailURL: URL? {
        #if os(macOS)
        let platform = "macOS"
        #else
        let platform = "iOS"
        #endif
        let os = ProcessInfo.processInfo.operatingSystemVersionString
        var parts = URLComponents()
        parts.scheme = "mailto"
        parts.path = supportEmail
        parts.queryItems = [
            URLQueryItem(name: "subject", value: "Simple Todo wish"),
            URLQueryItem(name: "body", value: "My wish:\n\n\n---\nSimple Todo \(version), \(platform) \(os)"),
        ]
        return parts.url
    }

    static var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }
}
