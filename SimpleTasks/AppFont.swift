import SwiftUI
import CoreText

/// Bundled fonts (Roboto, Lato, Open Sans) in the Fonts folder.
enum AppFont {
    /// Registers the bundled font files. Call once at launch.
    static func register() {
        let urls = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        for url in urls {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    enum Weight { case regular, medium, bold }

    /// A font in the chosen family and size. Sizes match the system text styles.
    static func make(_ weight: Weight, size: CGFloat, style: Font.TextStyle) -> Font {
        let settings = AppSettings.shared
        let custom = settings.fontSize == .custom
        let points = custom ? size * settings.fontScale : size

        guard let faces = settings.fontFamily.faces else {
            let w: Font.Weight = switch weight {
            case .regular: .regular
            case .medium: .medium
            case .bold: .bold
            }
            return custom ? .system(size: points, weight: w) : .system(style, weight: w)
        }
        let name = switch weight {
        case .regular: faces.regular
        case .medium: faces.medium
        case .bold: faces.bold
        }
        return custom ? .custom(name, fixedSize: points) : .custom(name, size: points, relativeTo: style)
    }
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

    // Computed each time, so a change on the Settings page shows right away.
    static var appBody: Font { AppFont.make(.regular, size: bodySize, style: .body) }
    static var appHeadline: Font { AppFont.make(.medium, size: bodySize, style: .headline) }
    static var appTab: Font { AppFont.make(.medium, size: subheadlineSize, style: .subheadline) }
    static var appFootnote: Font { AppFont.make(.regular, size: footnoteSize, style: .footnote) }
    static var appCaption: Font { AppFont.make(.regular, size: captionSize, style: .caption) }
    static var appTitle: Font { AppFont.make(.bold, size: titleSize, style: .title) }
}
