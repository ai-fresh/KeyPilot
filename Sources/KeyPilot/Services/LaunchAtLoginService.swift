import SwiftUI
import ServiceManagement

/// Service that manages the "Launch at Login" functionality
@Observable
final class LaunchAtLoginService {
    /// Current state of the Launch at Login setting
    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    /// Enable or disable Launch at Login
    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status == .enabled {
                    // Already enabled
                    return
                }
                try SMAppService.mainApp.register()
            } else {
                if SMAppService.mainApp.status == .notRegistered {
                    // Already disabled
                    return
                }
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error.localizedDescription)")
        }
    }

    /// Toggle the Launch at Login setting
    func toggle() {
        setEnabled(!isEnabled)
    }
}
