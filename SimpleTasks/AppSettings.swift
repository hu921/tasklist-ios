import SwiftUI
import Observation

/// Appearance and language choices from the Settings page. Saved on this device.
@Observable
final class AppSettings {
    static let shared = AppSettings()

    enum Theme: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: String { rawValue }

        var name: String {
            switch self {
            case .system: L("System")
            case .light: L("Light")
            case .dark: L("Dark")
            }
        }

        var colorScheme: ColorScheme? {
            switch self {
            case .system: nil
            case .light: .light
            case .dark: .dark
            }
        }
    }

    enum FontFamily: String, CaseIterable, Identifiable {
        case system, roboto, helveticaNeue, lato, openSans
        var id: String { rawValue }

        var name: String {
            switch self {
            case .system: L("System")
            case .roboto: "Roboto"
            case .helveticaNeue: "Helvetica Neue"
            case .lato: "Lato"
            case .openSans: "Open Sans"
            }
        }

        /// PostScript names for regular, medium, and bold. `nil` for the system font.
        var faces: (regular: String, medium: String, bold: String)? {
            switch self {
            case .system: nil
            case .roboto: ("Roboto-Regular", "Roboto-Medium", "Roboto-Bold")
            case .helveticaNeue: ("HelveticaNeue", "HelveticaNeue-Medium", "HelveticaNeue-Bold")
            case .lato: ("Lato-Regular", "Lato-Bold", "Lato-Bold")
            case .openSans: ("OpenSans-Regular", "OpenSans-SemiBold", "OpenSans-Bold")
            }
        }
    }

    enum Language: String, CaseIterable, Identifiable {
        case system, english = "en", chinese = "zh-Hant"
        var id: String { rawValue }

        /// Each language is shown in its own words.
        var name: String {
            switch self {
            case .system: L("System")
            case .english: "English"
            case .chinese: "繁體中文"
            }
        }
    }

    enum FontSize: String, CaseIterable, Identifiable {
        case system, custom
        var id: String { rawValue }

        var name: String {
            switch self {
            case .system: L("System")
            case .custom: L("Custom")
            }
        }
    }

    /// Slider range for a custom font size, as a share of the normal size.
    static let scaleRange: ClosedRange<Double> = 0.8...1.6

    var theme: Theme { didSet { save(theme.rawValue, "theme") } }
    var fontFamily: FontFamily { didSet { save(fontFamily.rawValue, "fontFamily") } }
    var fontSize: FontSize { didSet { save(fontSize.rawValue, "fontSize") } }
    var fontScale: Double { didSet { defaults.set(fontScale, forKey: "fontScale") } }
    var language: Language { didSet { save(language.rawValue, "language") } }

    @ObservationIgnored private let defaults = UserDefaults.standard

    private init() {
        let d = UserDefaults.standard
        theme = Theme(rawValue: d.string(forKey: "theme") ?? "") ?? .system
        // Roboto was the only font before this setting existed.
        fontFamily = FontFamily(rawValue: d.string(forKey: "fontFamily") ?? "") ?? .roboto
        fontSize = FontSize(rawValue: d.string(forKey: "fontSize") ?? "") ?? .system
        let scale = d.double(forKey: "fontScale")
        fontScale = scale == 0 ? 1 : min(max(scale, Self.scaleRange.lowerBound), Self.scaleRange.upperBound)
        language = Language(rawValue: d.string(forKey: "language") ?? "") ?? .system
    }

    private func save(_ value: String, _ key: String) {
        defaults.set(value, forKey: key)
        AppLog.log("setting \(key)", value)
    }

    /// The language the app's words are shown in.
    var activeLanguage: Language {
        if language != .system { return language }
        for code in Locale.preferredLanguages {
            if code.hasPrefix("zh-Hant") || code.hasPrefix("zh-TW") || code.hasPrefix("zh-HK") || code.hasPrefix("zh-MO") {
                return .chinese
            }
            if code.hasPrefix("en") { return .english }
        }
        return .english
    }

    /// Used for dates such as "Wednesday, November 11".
    var locale: Locale {
        language == .system ? .current : Locale(identifier: activeLanguage == .chinese ? "zh-Hant-TW" : "en")
    }

    @ObservationIgnored private var bundles: [Language: Bundle] = [:]

    fileprivate func bundle(for language: Language) -> Bundle {
        if let cached = bundles[language] { return cached }
        let found = Bundle.main.path(forResource: language.rawValue, ofType: "lproj").flatMap(Bundle.init(path:)) ?? .main
        bundles[language] = found
        return found
    }
}

/// The app's words in the chosen language, e.g. `L("Daily")`.
/// Words with numbers use format keys, e.g. `L("%lld of %lld done", 2, 5)`.
func L(_ key: String, _ args: CVarArg...) -> String {
    let settings = AppSettings.shared
    let text = settings.bundle(for: settings.activeLanguage).localizedString(forKey: key, value: key, table: nil)
    return args.isEmpty ? text : String(format: text, locale: settings.locale, arguments: args)
}
