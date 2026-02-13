import SwiftUI

@main
struct KeyPilotApp: App {
    @State private var profileStore: ProfileStore
    @State private var appMonitor: AppMonitorService
    @State private var profileSwitcher: ProfileSwitcher
    @State private var launchAtLoginService = LaunchAtLoginService()

    init() {
        let store = ProfileStore()
        let monitor = AppMonitorService()
        let keyboard = KeyboardService()
        let switcher = ProfileSwitcher(
            profileStore: store,
            keyboardService: keyboard,
            appMonitor: monitor
        )

        _profileStore = State(initialValue: store)
        _appMonitor = State(initialValue: monitor)
        _profileSwitcher = State(initialValue: switcher)

        // Start monitoring right away
        monitor.start()

        // Upload default/matching profile on launch
        let currentBundleID = monitor.currentBundleID
        let initialProfile: Profile?
        if let bid = currentBundleID, let matched = store.profile(for: bid) {
            initialProfile = matched
        } else {
            initialProfile = store.defaultProfile()
        }

        if let profile = initialProfile {
            Task {
                await switcher.activateProfile(profile)
            }
        }
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(
                profileSwitcher: profileSwitcher,
                profileStore: profileStore,
                launchAtLoginService: launchAtLoginService
            )
        } label: {
            Label("KeyPilot", systemImage: "keyboard.fill")
        }

        Window("KeyPilot — Profiles", id: "settings") {
            ProfileEditorView(
                profileStore: profileStore,
                profileSwitcher: profileSwitcher
            )
            .frame(minWidth: 600, minHeight: 400)
        }
        .defaultSize(width: 750, height: 500)
    }
}
