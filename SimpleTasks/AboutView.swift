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
                        Text("A simple daily, weekly, and monthly to-do list.")
                            .font(.appFootnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                Section {
                    LabeledContent("Version", value: AppInfo.version)
                    if let name = AppInfo.developerName {
                        LabeledContent("Developer", value: name)
                    }
                    if let mail = AppInfo.contactMailURL {
                        LabeledContent("Contact") {
                            Link(AppInfo.supportEmail, destination: mail)
                        }
                    }
                    if let website = AppInfo.website {
                        LabeledContent("Website") {
                            Link(website.host() ?? website.absoluteString, destination: website)
                        }
                    }
                }

                Section {
                    Button {
                        isWishing = true
                    } label: {
                        Label("Send a wish", systemImage: "sparkles")
                    }
                } footer: {
                    Text("Share an idea or a problem, right here in the app.")
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
                            Text(message)
                                .font(.appFootnote)
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("Tip jar")
                    } footer: {
                        Text("Optional. Tips support the app and unlock nothing.")
                            .font(.appFootnote)
                    }
                }

                Section("iCloud sync") {
                    LabeledContent("Storage", value: sync.storage)
                    LabeledContent("iCloud account", value: sync.account)
                    LabeledContent("Last sync", value: sync.lastSync)
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
                            Label("Share log", systemImage: "square.and.arrow.up")
                        }
                        Button {
                            logFile = LogDocument(data: (try? Data(contentsOf: AppLog.fileURL)) ?? Data())
                            isSavingLog = true
                        } label: {
                            Label("Save log to file…", systemImage: "square.and.arrow.down")
                        }
                    } header: {
                        Text("Testing")
                    } footer: {
                        Text("Actions, sync, and errors only. No task text. Test builds only.")
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
            .navigationTitle("About")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 360, minHeight: 380)
        #endif
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
