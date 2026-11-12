import SwiftUI
import CoreText

/// Roboto, bundled in the Fonts folder. Sizes match the system text styles.
enum AppFont {
    /// Registers the bundled Roboto files. Call once at launch.
    static func register() {
        let urls = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        for url in urls {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static let regular = "Roboto-Regular"
    static let medium = "Roboto-Medium"
    static let bold = "Roboto-Bold"
}

extension Font {
    #if os(macOS)
    private static let bodySize: CGFloat = 13
    private static let subheadlineSize: CGFloat = 11
    private static let footnoteSize: CGFloat = 10
    private static let captionSize: CGFloat = 10
    private static let titleSize: CGFloat = 22
    #else
    private static let bodySize: CGFloat = 17
    private static let subheadlineSize: CGFloat = 15
    private static let footnoteSize: CGFloat = 13
    private static let captionSize: CGFloat = 12
    private static let titleSize: CGFloat = 28
    #endif

    static let appBody = Font.custom(AppFont.regular, size: bodySize, relativeTo: .body)
    static let appHeadline = Font.custom(AppFont.medium, size: bodySize, relativeTo: .headline)
    static let appTab = Font.custom(AppFont.medium, size: subheadlineSize, relativeTo: .subheadline)
    static let appFootnote = Font.custom(AppFont.regular, size: footnoteSize, relativeTo: .footnote)
    static let appCaption = Font.custom(AppFont.regular, size: captionSize, relativeTo: .caption)
    static let appTitle = Font.custom(AppFont.bold, size: titleSize, relativeTo: .title)
}
