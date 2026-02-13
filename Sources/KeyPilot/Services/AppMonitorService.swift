import AppKit
import Foundation
import Observation
import os

private let logger = Logger(subsystem: "com.keypilot.app", category: "AppMonitor")

@Observable
@MainActor
final class AppMonitorService {
    private(set) var currentBundleID: String?
    private(set) var currentAppName: String?
    private var observation: NSObjectProtocol?

    var onAppChanged: (@MainActor @Sendable (String, String?) -> Void)?

    func start() {
        if let app = NSWorkspace.shared.frontmostApplication {
            currentBundleID = app.bundleIdentifier
            currentAppName = app.localizedName
            logger.info(
                "Initial app: \(app.localizedName ?? "?") (\(app.bundleIdentifier ?? "?"))"
            )
        }

        observation = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let app =
                notification.userInfo?[NSWorkspace.applicationUserInfoKey]
                as? NSRunningApplication
            let bundleID = app?.bundleIdentifier ?? "unknown"
            let appName = app?.localizedName

            MainActor.assumeIsolated {
                logger.info("Detected app switch: \(appName ?? "?") (\(bundleID))")
                self?.currentBundleID = bundleID
                self?.currentAppName = appName
                self?.onAppChanged?(bundleID, appName)
            }
        }

        logger.info("AppMonitor started")
    }

    func stop() {
        if let observation {
            NSWorkspace.shared.notificationCenter.removeObserver(observation)
        }
        observation = nil
        logger.info("AppMonitor stopped")
    }
}
