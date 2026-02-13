import Foundation

struct Profile: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var name: String
    var icon: String
    var bundleIdentifiers: [String]
    var isDefault: Bool
    var keyMapping: KeyMapping

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "⌨️",
        bundleIdentifiers: [String] = [],
        isDefault: Bool = false,
        keyMapping: KeyMapping = .empty
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.bundleIdentifiers = bundleIdentifiers
        self.isDefault = isDefault
        self.keyMapping = keyMapping
    }
}
