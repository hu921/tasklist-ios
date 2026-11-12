import Foundation

/// Shown on the About page.
enum AppInfo {
    static let developerName = "Your Name"
    static let email = "you@example.com"
    static let website = URL(string: "https://example.com")!

    static var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }
}
