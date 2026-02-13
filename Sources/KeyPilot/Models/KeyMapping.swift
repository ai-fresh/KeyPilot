import Foundation

struct KeyMapping: Codable, Hashable, Sendable {
    var button1: String
    var button2: String
    var button3: String
    var knobCCW: String
    var knobPress: String
    var knobCW: String

    static let empty = KeyMapping(
        button1: "", button2: "", button3: "",
        knobCCW: "", knobPress: "", knobCW: ""
    )

    // MARK: - Validation

    static let validKeys: Set<String> = [
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
        "enter", "escape", "backspace", "tab", "space",
        "minus", "equal", "leftbracket", "rightbracket", "backslash",
        "semicolon", "quote", "grave", "comma", "dot", "slash",
        "capslock", "printscreen", "insert", "home", "pageup",
        "delete", "end", "pagedown", "right", "left", "down", "up",
        "numlock", "numpadslash", "numpadasterisk", "numpadminus",
        "numpadplus", "numpadenter",
        "numpad0", "numpad1", "numpad2", "numpad3", "numpad4",
        "numpad5", "numpad6", "numpad7", "numpad8", "numpad9",
        "numpaddot", "application", "power",
        "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10",
        "f11", "f12", "f13", "f14", "f15", "f16", "f17", "f18",
        "f19", "f20", "f21", "f22", "f23", "f24",
        "macbrightnessdown", "macbrightnessup",
    ]

    static let validMediaKeys: Set<String> = [
        "next", "previous", "prev", "stop", "play", "mute",
        "volumeup", "volumedown", "favorites", "calculator", "screenlock",
    ]

    static let validModifiers: Set<String> = [
        "ctrl", "shift", "alt", "opt", "win", "cmd",
        "rctrl", "rshift", "ralt", "ropt", "rwin", "rcmd",
    ]

    static func isValidMapping(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return false }

        // Media keys cannot be combined with modifiers
        if validMediaKeys.contains(trimmed) { return true }

        // Mouse actions: click(), move(), drag(), wheel()
        if trimmed.hasPrefix("click") || trimmed.hasPrefix("move")
            || trimmed.hasPrefix("drag") || trimmed.hasPrefix("wheel")
        {
            return true
        }

        // Custom key code: <110>
        if trimmed.hasPrefix("<") && trimmed.hasSuffix(">") { return true }

        // Standard key with optional modifiers: "cmd-shift-b"
        let parts = trimmed.split(separator: "-").map(String.init)
        guard !parts.isEmpty else { return false }

        let key = parts.last!
        let modifiers = parts.dropLast()

        let keyValid = validKeys.contains(key)
        let modsValid = modifiers.allSatisfy { validModifiers.contains($0) }
        return keyValid && modsValid
    }
}
