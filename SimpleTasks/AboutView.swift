import SwiftUI
import UniformTypeIdentifiers

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    private var sync = SyncStatus.shared
    /// Shown only in Xcode and TestFlight builds.
    @State private var isTestBuild = false
    @State private var isSavingLog = false
    @State private var logFile: LogDocument?

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
                    if let email = AppInfo.email, let mail = URL(string: "mailto:\(email)") {
                        LabeledContent("Email") {
                            Link(email, destination: mail)
                        }
                    }
                    if let website = AppInfo.website {
                        LabeledContent("Website") {
                            Link(website.host() ?? website.absoluteString, destination: website)
                        }
                    }
                }

                if let wish = AppInfo.wishMailURL {
                    Section {
                        Link(destination: wish) {
                            Label("Send a wish", systemImage: "sparkles")
                        }
                    } footer: {
                        Text("Ideas or problems? Email \(AppInfo.supportEmail).")
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
            }
            .font(.appBody)
            .task {
                await sync.checkAccount()
                isTestBuild = await AppLog.isTestBuild()
            }
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
