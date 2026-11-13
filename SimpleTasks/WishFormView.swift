import SwiftUI
import CloudKit

/// "Send a wish": the user types a wish in the app. It is saved to the app's
/// public iCloud database as a "Wish" record. The developer reads wishes in the
/// CloudKit console. No email app opens. Only the text and app version are sent.
struct WishFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var isSending = false
    @State private var errorText: String?
    @State private var sent = false
    @FocusState private var isFocused: Bool

    static let maxLength = 1000

    private var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                if sent {
                    Section {
                        Label("Thank you! We read every wish.", systemImage: "sparkles")
                    }
                } else {
                    Section {
                        TextEditor(text: $text)
                            .frame(minHeight: 160)
                            .focused($isFocused)
                            .onChange(of: text) { _, new in
                                if new.count > Self.maxLength { text = String(new.prefix(Self.maxLength)) }
                            }
                    } header: {
                        Text("Your wish")
                    } footer: {
                        Text("An idea, a problem, or a feature you'd like. We read every wish. Only this text and the app version are sent.")
                            .font(.appFootnote)
                    }
                    if let errorText {
                        Text(errorText)
                            .font(.appFootnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .font(.appBody)
            .navigationTitle(sent ? "Wish sent" : "Send a wish")
            .toolbar {
                if sent {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                } else {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if isSending {
                            ProgressView()
                        } else {
                            Button("Send") { Task { await send() } }
                                .disabled(trimmed.isEmpty)
                        }
                    }
                }
            }
            .onAppear { isFocused = true }
        }
        #if os(macOS)
        .frame(minWidth: 380, minHeight: 320)
        #endif
    }

    private func send() async {
        isSending = true
        errorText = nil
        defer { isSending = false }
        let record = CKRecord(recordType: "Wish")
        record["text"] = trimmed
        record["app"] = AppInfo.deviceInfo
        do {
            _ = try await CKContainer(identifier: SyncStatus.containerID).publicCloudDatabase.save(record)
            isFocused = false
            sent = true
            AppLog.log("wish sent", "\(trimmed.count) chars")
        } catch {
            let ns = error as NSError
            if ns.domain == CKError.errorDomain, ns.code == CKError.notAuthenticated.rawValue {
                errorText = "Please sign in to iCloud in Settings to send a wish."
            } else {
                errorText = "Could not send. Please check your internet and try again."
            }
            AppLog.error("wish failed", error)
        }
    }
}

#Preview {
    WishFormView()
}
