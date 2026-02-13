import SwiftUI

struct MenuBarView: View {
    let profileSwitcher: ProfileSwitcher
    let profileStore: ProfileStore
    let launchAtLoginService: LaunchAtLoginService
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        // Status
        if let active = profileSwitcher.activeProfile {
            HStack {
                Text("\(active.icon) \(active.name)")
                if profileSwitcher.isUploading {
                    ProgressView()
                        .scaleEffect(0.5)
                }
            }
        } else {
            Text("No active profile")
                .foregroundStyle(.secondary)
        }

        if let error = profileSwitcher.lastUploadError {
            Label(error, systemImage: "exclamationmark.triangle")
                .foregroundStyle(.red)
                .font(.caption)
        }

        if let appName = profileSwitcher.appMonitor.currentAppName {
            Text("App: \(appName)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }

        Divider()

        // Profile list
        ForEach(profileStore.profiles) { profile in
            Button {
                Task {
                    await profileSwitcher.activateProfile(profile, manual: true)
                }
            } label: {
                HStack {
                    Text("\(profile.icon) \(profile.name)")
                    Spacer()
                    if profile.id == profileSwitcher.activeProfile?.id {
                        Text("✓")
                    }
                    if profile.isDefault {
                        Text("Default").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
        }

        Divider()

        // Auto-switch toggle
        Toggle(
            "Auto-switch",
            isOn: Binding(
                get: { profileSwitcher.autoSwitchEnabled },
                set: { newValue in
                    profileSwitcher.autoSwitchEnabled = newValue
                    if newValue {
                        profileSwitcher.clearManualOverride()
                    }
                }
            ))

        // Launch at Login toggle
        Toggle(
            "Launch at Login",
            isOn: Binding(
                get: { launchAtLoginService.isEnabled },
                set: { newValue in
                    launchAtLoginService.setEnabled(newValue)
                }
            ))

        Button("Re-upload Current Profile") {
            Task { await profileSwitcher.forceReupload() }
        }
        .disabled(profileSwitcher.activeProfile == nil)

        Divider()

        Button("Edit Profiles...") {
            openWindow(id: "settings")
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
        .keyboardShortcut(",", modifiers: .command)

        Divider()

        Button("Quit KeyPilot") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
