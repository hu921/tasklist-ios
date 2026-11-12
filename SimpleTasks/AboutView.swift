import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

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
            }
            .font(.appBody)
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
