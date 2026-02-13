import SwiftUI

struct ProfileFormView: View {
    @State var profile: Profile
    let isUploading: Bool
    let uploadError: String?
    let onSave: (Profile) -> Void

    @State private var newBundleID: String = ""

    var body: some View {
        Form {
            Section("Profile Info") {
                HStack {
                    TextField("Icon", text: $profile.icon)
                        .frame(width: 60)
                    TextField("Name", text: $profile.name)
                }
                Toggle("Default Profile", isOn: $profile.isDefault)
                    .help("Default profile is used when no app-specific profile matches")
            }

            Section("Associated Applications") {
                if profile.bundleIdentifiers.isEmpty && !profile.isDefault {
                    Text("No apps assigned. This profile can only be activated manually.")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }

                ForEach(profile.bundleIdentifiers.indices, id: \.self) { index in
                    HStack {
                        Text(appName(for: profile.bundleIdentifiers[index]))
                            .foregroundStyle(.secondary)
                            .frame(width: 120, alignment: .leading)
                        TextField("Bundle ID", text: $profile.bundleIdentifiers[index])
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                        Button(role: .destructive) {
                            profile.bundleIdentifiers.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.borderless)
                    }
                }

                HStack {
                    TextField("Add bundle ID...", text: $newBundleID)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .onSubmit { addBundleID() }
                    Button("Add") { addBundleID() }
                        .disabled(newBundleID.isEmpty)
                }

                DisclosureGroup("Running Apps") {
                    runningAppsView
                }
                .font(.caption)
            }

            Section("Buttons — click to record shortcut") {
                KeyRecorderField(label: "Button 1 (Left)", value: $profile.keyMapping.button1)
                KeyRecorderField(label: "Button 2 (Middle)", value: $profile.keyMapping.button2)
                KeyRecorderField(label: "Button 3 (Right)", value: $profile.keyMapping.button3)
            }

            Section("Knob (Rotary Encoder)") {
                KeyRecorderField(label: "Rotate Left", value: $profile.keyMapping.knobCCW)
                KeyRecorderField(label: "Press", value: $profile.keyMapping.knobPress)
                KeyRecorderField(label: "Rotate Right", value: $profile.keyMapping.knobCW)

                Text("For volume/media: type manually — volumeup, volumedown, mute, play, next, prev")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let error = uploadError {
                Section {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Upload Failed")
                                .font(.headline)
                            Text(error)
                                .font(.caption)
                        }
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 8) {
                    if isUploading {
                        ProgressView()
                            .scaleEffect(0.7)
                            .help("Uploading to device...")
                    }

                    Button("Save") {
                        onSave(profile)
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(isUploading)
                }
            }
        }
    }

    // MARK: - Running Apps Picker

    private var runningAppsView: some View {
        let apps =
            NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app -> (String, String)? in
                guard let bundleID = app.bundleIdentifier,
                    let name = app.localizedName
                else { return nil }
                return (name, bundleID)
            }
            .sorted { $0.0 < $1.0 }

        return VStack(alignment: .leading, spacing: 2) {
            ForEach(apps, id: \.1) { name, bundleID in
                Button {
                    if !profile.bundleIdentifiers.contains(bundleID) {
                        profile.bundleIdentifiers.append(bundleID)
                    }
                } label: {
                    HStack {
                        Text(name)
                            .frame(width: 150, alignment: .leading)
                        Text(bundleID)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Spacer()
                        if profile.bundleIdentifiers.contains(bundleID) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Helpers

    private func addBundleID() {
        let trimmed = newBundleID.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !profile.bundleIdentifiers.contains(trimmed) else { return }
        profile.bundleIdentifiers.append(trimmed)
        newBundleID = ""
    }

    private func appName(for bundleID: String) -> String {
        NSWorkspace.shared.runningApplications
            .first { $0.bundleIdentifier == bundleID }?
            .localizedName ?? ""
    }
}
