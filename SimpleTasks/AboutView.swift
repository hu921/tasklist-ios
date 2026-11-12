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
                        Text("Simple Tasks")
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
                    LabeledContent("Developer", value: AppInfo.developerName)
                    LabeledContent("Email") {
                        Link(AppInfo.email, destination: URL(string: "mailto:\(AppInfo.email)")!)
                    }
                    LabeledContent("Website") {
                        Link(AppInfo.website.host() ?? AppInfo.website.absoluteString,
                             destination: AppInfo.website)
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
