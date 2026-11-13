import SwiftUI
import UniformTypeIdentifiers

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    private var sync = SyncStatus.shared
    private var tips = TipJar.shared
    /// Shown only in Xcode and TestFlight builds.
    @State private var isTestBuild = false
    @State private var isSavingLog = false
    @State private var logFile: LogDocument?
    @State private var isWishing = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.square.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.tint)
                        Text("Simple Todo")
                            .font(.appTitle)
                        Text(L("A simple daily, weekly, and monthly to-do list."))
                            .font(.appFootnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                Section {
                    LabeledContent(L("Version"), value: AppInfo.version)
                    if let name = AppInfo.developerName {
                        LabeledContent(L("Developer"), value: name)
                    }
                    if let mail = AppInfo.contactMailURL {
                        LabeledContent(L("Contact")) {
                            Link(AppInfo.supportEmail, destination: mail)
                        }
                    }
                    if let website = AppInfo.website {
                        LabeledContent(L("Website")) {
                            Link(website.host() ?? website.absoluteString, destination: website)
                        }
                    }
                }

                Section {
                    Button {
                        isWishing = true
                    } label: {
                        Label(L("Send a wish"), systemImage: "sparkles")
                    }
                } footer: {
                    Text(L("Share an idea or a problem, right here in the app."))
                        .font(.appFootnote)
                }

                if !tips.products.isEmpty {
                    Section {
                        ForEach(tips.products, id: \.id) { product in
                            Button {
                                Task { await tips.buy(product) }
                            } label: {
                                LabeledContent {
                                    Text(product.displayPrice)
                                } label: {
                                    Label(product.displayName, systemImage: "heart")
                                }
                            }
                            .disabled(tips.isBuying)
                        }
                        if let message = tips.message {
                            Text(L(message))
                                .font(.appFootnote)
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text(L("Tip jar"))
                    } footer: {
                        Text(L("Optional. Tips support the app and unlock nothing."))
                            .font(.appFootnote)
                    }
                }

                AppearanceSection()

                Section(L("iCloud sync")) {
                    LabeledContent(L("Storage"), value: L(sync.storage))
                    LabeledContent(L("iCloud account"), value: L(sync.account))
                    LabeledContent(L("Last sync"), value: sync.lastSyncText)
                    if let error = sync.lastError {
                        Text(error)
                            .font(.appFootnote)
                            .foregroundStyle(.red)
                            .textSelection(.enabled)
                    }
                }

                if isTestBuild {
                    Section {
                        ShareLink(item: AppLog.fileURL) {
                            Label(L("Share log"), systemImage: "square.and.arrow.up")
                        }
                        Button {
                            logFile = LogDocument(data: (try? Data(contentsOf: AppLog.fileURL)) ?? Data())
                            isSavingLog = true
                        } label: {
                            Label(L("Save log to file…"), systemImage: "square.and.arrow.down")
                        }
                    } header: {
                        Text(L("Testing"))
                    } footer: {
                        Text(L("Actions, sync, and errors only. No task text. Test builds only."))
                            .font(.appFootnote)
                    }
                }

                Section {
                } footer: {
                    Text("© \(AppInfo.copyrightYear) Simple Todo by Journipod")
                        .font(.appFootnote)
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.appBody)
            .task {
                await sync.checkAccount()
                isTestBuild = await AppLog.isTestBuild()
            }
            .task { await tips.start() }
            .sheet(isPresented: $isWishing) { WishFormView() }
            .fileExporter(
                isPresented: $isSavingLog,
                document: logFile,
                contentType: .plainText,
                defaultFilename: "SimpleTodo-log"
            ) { result in
                if case .failure(let error) = result { AppLog.error("save log failed", error) }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("Done")) { dismiss() }
                }
            }
        }
        .preferredColorScheme(AppSettings.shared.theme.colorScheme)
        #if os(macOS)
        .frame(minWidth: 360, minHeight: 380)
        #endif
    }
}

/// Theme, font, font size, and language.
private struct AppearanceSection: View {
    @Bindable private var settings = AppSettings.shared

    var body: some View {
        Section(L("Appearance")) {
            SettingPicker(L("Theme"), selection: $settings.theme) {
                ForEach(AppSettings.Theme.allCases) { Text($0.name).tag($0) }
            }
            SettingPicker(L("Font"), selection: $settings.fontFamily) {
                ForEach(AppSettings.FontFamily.allCases) { family in
                    Text(family.name).tag(family)
                }
            }
            SettingPicker(L("Font size"), selection: $settings.fontSize) {
                ForEach(AppSettings.FontSize.allCases) { Text($0.name).tag($0) }
            }
            if settings.fontSize == .custom {
                HStack(spacing: 12) {
                    Text("A").font(.system(size: 13))
                    Slider(value: $settings.fontScale, in: AppSettings.scaleRange, step: 0.1)
                        .accessibilityLabel(L("Font size"))
                    Text("A").font(.system(size: 22))
                }
            }
            SettingPicker(L("Language"), selection: $settings.language) {
                ForEach(AppSettings.Language.allCases) { Text($0.name).tag($0) }
            }
        }
    }
}

#Preview {
    AboutView()
}

/// The log as a plain text file, for "Save log to file…".
struct LogDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

/// A setting row whose menu button has the same width on every row (Mac).
private struct SettingPicker<Value: Hashable, Options: View>: View {
    let title: String
    @Binding var selection: Value
    @ViewBuilder let options: () -> Options

    init(_ title: String, selection: Binding<Value>, @ViewBuilder options: @escaping () -> Options) {
        self.title = title
        self._selection = selection
        self.options = options
    }

    var body: some View {
        #if os(macOS)
        LabeledContent(title) {
            Picker(title, selection: $selection, content: options)
                .labelsHidden()
                .frame(width: 170)
        }
        #else
        Picker(title, selection: $selection, content: options)
        #endif
    }
}
