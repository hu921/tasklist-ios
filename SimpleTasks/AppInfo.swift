import Foundation

/// Shown on the About page. Rows with `nil` are hidden.
enum AppInfo {
    static let developerName: String? = nil
    static let email: String? = nil
    static let website: URL? = nil

    static var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }
}
