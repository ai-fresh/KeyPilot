import Foundation
import Observation

@Observable
@MainActor
final class ProfileStore {
    private(set) var profiles: [Profile] = []
    private let fileURL: URL

    init() {
        let appSupport =
            FileManager.default.urls(
                for: .applicationSupportDirectory, in: .userDomainMask
            ).first!.appendingPathComponent("KeyPilot")

        try? FileManager.default.createDirectory(
            at: appSupport, withIntermediateDirectories: true
        )

        self.fileURL = appSupport.appendingPathComponent("profiles.json")
        load()

        if profiles.isEmpty {
            seedDefaultProfiles()
        }
    }

    // MARK: - Persistence

    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            profiles = try JSONDecoder().decode([Profile].self, from: data)
        } catch {
            print("KeyPilot: Failed to load profiles: \(error)")
            profiles = []
        }
    }

    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(profiles)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("KeyPilot: Failed to save profiles: \(error)")
        }
    }

    // MARK: - CRUD

    func add(_ profile: Profile) {
        profiles.append(profile)
        save()
    }

    func update(_ profile: Profile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            save()
        }
    }

    func delete(_ profile: Profile) {
        profiles.removeAll { $0.id == profile.id }
        save()
    }

    func defaultProfile() -> Profile? {
        profiles.first(where: \.isDefault)
    }

    func profile(for bundleID: String) -> Profile? {
        profiles.first { $0.bundleIdentifiers.contains(bundleID) }
    }

    func setAsDefault(_ profile: Profile) {
        for i in profiles.indices {
            profiles[i].isDefault = (profiles[i].id == profile.id)
        }
        save()
    }

    // MARK: - Seed Defaults

    private func seedDefaultProfiles() {
        profiles = [
            Profile(
                name: "Whispering",
                icon: "🎤",
                bundleIdentifiers: ["app.whispering"],
                isDefault: false,
                keyMapping: KeyMapping(
                    button1: "f13", button2: "f19", button3: "f20",
                    knobCCW: "volumedown", knobPress: "mute", knobCW: "volumeup"
                )
            ),
            Profile(
                name: "Final Cut Pro",
                icon: "🎬",
                bundleIdentifiers: ["com.apple.FinalCut"],
                isDefault: false,
                keyMapping: KeyMapping(
                    button1: "cmd-b",
                    button2: "cmd-leftbracket",
                    button3: "cmd-rightbracket",
                    knobCCW: "left", knobPress: "space", knobCW: "right"
                )
            ),
            Profile(
                name: "Default",
                icon: "⌨️",
                bundleIdentifiers: [],
                isDefault: true,
                keyMapping: KeyMapping(
                    button1: "cmd-c", button2: "cmd-v", button3: "cmd-z",
                    knobCCW: "volumedown", knobPress: "mute", knobCW: "volumeup"
                )
            ),
        ]
        save()
    }
}
