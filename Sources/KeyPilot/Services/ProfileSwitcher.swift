import Foundation
import Observation
import os

private let logger = Logger(subsystem: "com.keypilot.app", category: "ProfileSwitcher")

@Observable
@MainActor
final class ProfileSwitcher {
    let profileStore: ProfileStore
    let keyboardService: KeyboardService
    let appMonitor: AppMonitorService

    private(set) var activeProfile: Profile?
    private(set) var lastUploadError: String?
    private(set) var isUploading: Bool = false

    var autoSwitchEnabled: Bool {
        didSet { UserDefaults.standard.set(autoSwitchEnabled, forKey: "autoSwitchEnabled") }
    }

    private var manualOverrideActive: Bool = false
    private var debounceTask: Task<Void, Never>?
    private var lastUploadedProfileID: UUID?

    init(
        profileStore: ProfileStore,
        keyboardService: KeyboardService,
        appMonitor: AppMonitorService
    ) {
        self.profileStore = profileStore
        self.keyboardService = keyboardService
        self.appMonitor = appMonitor
        self.autoSwitchEnabled =
            UserDefaults.standard.object(forKey: "autoSwitchEnabled") != nil
            ? UserDefaults.standard.bool(forKey: "autoSwitchEnabled")
            : true

        appMonitor.onAppChanged = { [weak self] bundleID, appName in
            logger.info("App changed: \(appName ?? "?") (\(bundleID))")
            self?.handleAppChange(bundleID: bundleID)
        }
    }

    private func handleAppChange(bundleID: String) {
        guard autoSwitchEnabled, !manualOverrideActive else {
            logger.debug(
                "Skipping switch: autoSwitch=\(self.autoSwitchEnabled), manualOverride=\(self.manualOverrideActive)"
            )
            return
        }

        let matchedProfile = profileStore.profile(for: bundleID)
        let profile = matchedProfile ?? profileStore.defaultProfile()

        if let p = profile {
            logger.info(
                "Matched profile: \(p.name) (matched=\(matchedProfile != nil), default=\(matchedProfile == nil))"
            )
        } else {
            logger.warning("No profile found for \(bundleID) and no default set")
            return
        }

        guard let profile else { return }

        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await self?.activateProfile(profile)
        }
    }

    func activateProfile(_ profile: Profile, manual: Bool = false) async {
        if profile.id == lastUploadedProfileID {
            logger.debug("Same profile \(profile.name), skipping upload")
            activeProfile = profile
            return
        }

        if manual {
            manualOverrideActive = true
            logger.info("Manual override: \(profile.name)")
        }

        activeProfile = profile
        isUploading = true
        lastUploadError = nil

        logger.info("Uploading profile: \(profile.name)")

        do {
            try await keyboardService.upload(profile: profile)
            lastUploadedProfileID = profile.id
            logger.info("Upload success: \(profile.name)")
        } catch {
            lastUploadError = error.localizedDescription
            logger.error("Upload failed: \(error.localizedDescription)")
        }

        isUploading = false
    }

    /// Called when default profile changes — re-evaluate current state
    func onDefaultProfileChanged() {
        manualOverrideActive = false
        lastUploadedProfileID = nil  // Force re-upload

        if let bundleID = appMonitor.currentBundleID {
            // Check if current app has a specific profile
            if profileStore.profile(for: bundleID) != nil {
                handleAppChange(bundleID: bundleID)
            } else if let defaultProfile = profileStore.defaultProfile() {
                // Current app has no specific profile — use new default
                Task {
                    await activateProfile(defaultProfile)
                }
            }
        } else if let defaultProfile = profileStore.defaultProfile() {
            Task {
                await activateProfile(defaultProfile)
            }
        }
    }

    func clearManualOverride() {
        manualOverrideActive = false
        if let bundleID = appMonitor.currentBundleID {
            handleAppChange(bundleID: bundleID)
        }
    }

    func forceReupload() async {
        lastUploadedProfileID = nil
        if let profile = activeProfile {
            await activateProfile(profile)
        }
    }

    /// Upload profile configuration to device without activating it
    /// Used when saving profile changes in the editor
    func uploadOnSave(profile: Profile) async {
        isUploading = true
        lastUploadError = nil

        logger.info("Uploading profile on save: \(profile.name)")

        do {
            try await keyboardService.upload(profile: profile)

            // If this profile is currently active, update lastUploadedProfileID
            if profile.id == activeProfile?.id {
                lastUploadedProfileID = profile.id
            }

            logger.info("Save upload success: \(profile.name)")
        } catch {
            lastUploadError = error.localizedDescription
            logger.error("Save upload failed: \(error.localizedDescription)")
        }

        isUploading = false
    }
}
