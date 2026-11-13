import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    private var sync = SyncStatus.shared
    /// Shown only in Xcode and TestFlight builds.
    @State private var isTestBuild = false

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
