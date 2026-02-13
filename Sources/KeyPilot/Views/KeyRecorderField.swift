import AppKit
import Carbon.HIToolbox
import SwiftUI

struct KeyRecorderField: View {
    let label: String
    @Binding var value: String
    @State private var isRecording = false

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 140, alignment: .leading)
                .foregroundStyle(.secondary)

            ZStack {
                if isRecording {
                    HStack {
                        Image(systemName: "record.circle")
                            .foregroundStyle(.red)
                            .symbolEffect(.pulse, isActive: true)
                        Text("Press keys...")
                            .foregroundStyle(.red)
                        Spacer()
                        Button("Cancel") { isRecording = false }
                            .buttonStyle(.borderless)
                            .font(.caption)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(.red.opacity(0.5), lineWidth: 1.5)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.red.opacity(0.05))
                            )
                    )
                } else {
                    HStack {
                        if value.isEmpty {
                            Text("Click to record...")
                                .foregroundStyle(.tertiary)
                        } else {
                            Text(displayName(for: value))
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                        }
                        Spacer()
                        if !value.isEmpty {
                            Button {
                                value = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { isRecording = true }
                }
            }
            .frame(minWidth: 200)
            .background {
                if isRecording {
                    KeyRecorderRepresentable(
                        isRecording: $isRecording,
                        value: $value
                    )
                    .frame(width: 0, height: 0)
                }
            }

            // Fallback: manual text edit
            Button {
                // Toggle between recorder and manual input
            } label: {
                Image(systemName: "pencil.line")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .help("Type manually: e.g. cmd-c, f13, play")
            .popover(isPresented: .constant(false)) {
                TextField("e.g. cmd-c", text: $value)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .padding()
            }
        }
    }

    // Convert "cmd-shift-b" into "⌘⇧B" for display
    private func displayName(for mapping: String) -> String {
        let parts = mapping.split(separator: "-").map(String.init)
        guard !parts.isEmpty else { return mapping }

        // Check if it's a media key or mouse action (no modifiers)
        if parts.count == 1 {
            return prettyKeyName(parts[0])
        }

        let key = parts.last!
        let modifiers = parts.dropLast()

        let modSymbols = modifiers.compactMap { modifierSymbol($0) }
        let keyDisplay = prettyKeyName(key)

        return modSymbols.joined() + keyDisplay
    }

    private func modifierSymbol(_ mod: String) -> String? {
        switch mod.lowercased() {
        case "ctrl", "rctrl": return "⌃"
        case "alt", "opt", "ralt", "ropt": return "⌥"
        case "shift", "rshift": return "⇧"
        case "cmd", "win", "rcmd", "rwin": return "⌘"
        default: return nil
        }
    }

    private func prettyKeyName(_ key: String) -> String {
        switch key.lowercased() {
        case "space": return "Space"
        case "enter": return "↩"
        case "escape": return "⎋"
        case "backspace": return "⌫"
        case "delete": return "⌦"
        case "tab": return "⇥"
        case "left": return "←"
        case "right": return "→"
        case "up": return "↑"
        case "down": return "↓"
        case "home": return "↖"
        case "end": return "↘"
        case "pageup": return "⇞"
        case "pagedown": return "⇟"
        case "leftbracket": return "["
        case "rightbracket": return "]"
        case "backslash": return "\\"
        case "slash": return "/"
        case "semicolon": return ";"
        case "quote": return "'"
        case "grave": return "`"
        case "comma": return ","
        case "dot": return "."
        case "minus": return "-"
        case "equal": return "="
        case "volumeup": return "🔊 Vol+"
        case "volumedown": return "🔉 Vol-"
        case "mute": return "🔇 Mute"
        case "play": return "⏯ Play"
        case "next": return "⏭ Next"
        case "prev", "previous": return "⏮ Prev"
        case "stop": return "⏹ Stop"
        default:
            // F-keys and letters
            return key.uppercased()
        }
    }
}

// MARK: - NSView-based Key Recorder

struct KeyRecorderRepresentable: NSViewRepresentable {
    @Binding var isRecording: Bool
    @Binding var value: String

    func makeNSView(context: Context) -> KeyRecorderNSView {
        let view = KeyRecorderNSView()
        view.onKeyRecorded = { recorded in
            value = recorded
            isRecording = false
        }
        view.onCancel = {
            isRecording = false
        }
        // Become first responder in next runloop
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: KeyRecorderNSView, context: Context) {
        if isRecording {
            DispatchQueue.main.async {
                nsView.window?.makeFirstResponder(nsView)
            }
        }
    }
}

class KeyRecorderNSView: NSView {
    var onKeyRecorded: ((String) -> Void)?
    var onCancel: (() -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        let mapping = buildMapping(from: event)
        if let mapping {
            onKeyRecorded?(mapping)
        }
    }

    override func flagsChanged(with event: NSEvent) {
        // Ignore standalone modifier presses
    }

    private func buildMapping(from event: NSEvent) -> String? {
        let keyCode = event.keyCode
        let flags = event.modifierFlags

        // Escape cancels recording
        if keyCode == UInt16(kVK_Escape) {
            onCancel?()
            return nil
        }

        var parts: [String] = []

        // Modifiers
        if flags.contains(.control) { parts.append("ctrl") }
        if flags.contains(.option) { parts.append("alt") }
        if flags.contains(.shift) { parts.append("shift") }
        if flags.contains(.command) { parts.append("cmd") }

        // Map keyCode to ch57x-keyboard-tool key name
        if let keyName = keyCodeToName(keyCode) {
            parts.append(keyName)
            return parts.joined(separator: "-")
        }

        return nil
    }

    // Map macOS virtual key codes to ch57x-keyboard-tool key names
    private func keyCodeToName(_ keyCode: UInt16) -> String? {
        switch Int(keyCode) {
        case kVK_ANSI_A: return "a"
        case kVK_ANSI_B: return "b"
        case kVK_ANSI_C: return "c"
        case kVK_ANSI_D: return "d"
        case kVK_ANSI_E: return "e"
        case kVK_ANSI_F: return "f"
        case kVK_ANSI_G: return "g"
        case kVK_ANSI_H: return "h"
        case kVK_ANSI_I: return "i"
        case kVK_ANSI_J: return "j"
        case kVK_ANSI_K: return "k"
        case kVK_ANSI_L: return "l"
        case kVK_ANSI_M: return "m"
        case kVK_ANSI_N: return "n"
        case kVK_ANSI_O: return "o"
        case kVK_ANSI_P: return "p"
        case kVK_ANSI_Q: return "q"
        case kVK_ANSI_R: return "r"
        case kVK_ANSI_S: return "s"
        case kVK_ANSI_T: return "t"
        case kVK_ANSI_U: return "u"
        case kVK_ANSI_V: return "v"
        case kVK_ANSI_W: return "w"
        case kVK_ANSI_X: return "x"
        case kVK_ANSI_Y: return "y"
        case kVK_ANSI_Z: return "z"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_Return: return "enter"
        case kVK_Tab: return "tab"
        case kVK_Space: return "space"
        case kVK_Delete: return "backspace"
        case kVK_ForwardDelete: return "delete"
        case kVK_ANSI_Minus: return "minus"
        case kVK_ANSI_Equal: return "equal"
        case kVK_ANSI_LeftBracket: return "leftbracket"
        case kVK_ANSI_RightBracket: return "rightbracket"
        case kVK_ANSI_Backslash: return "backslash"
        case kVK_ANSI_Semicolon: return "semicolon"
        case kVK_ANSI_Quote: return "quote"
        case kVK_ANSI_Grave: return "grave"
        case kVK_ANSI_Comma: return "comma"
        case kVK_ANSI_Period: return "dot"
        case kVK_ANSI_Slash: return "slash"
        case kVK_CapsLock: return "capslock"
        case kVK_LeftArrow: return "left"
        case kVK_RightArrow: return "right"
        case kVK_UpArrow: return "up"
        case kVK_DownArrow: return "down"
        case kVK_Home: return "home"
        case kVK_End: return "end"
        case kVK_PageUp: return "pageup"
        case kVK_PageDown: return "pagedown"
        case kVK_F1: return "f1"
        case kVK_F2: return "f2"
        case kVK_F3: return "f3"
        case kVK_F4: return "f4"
        case kVK_F5: return "f5"
        case kVK_F6: return "f6"
        case kVK_F7: return "f7"
        case kVK_F8: return "f8"
        case kVK_F9: return "f9"
        case kVK_F10: return "f10"
        case kVK_F11: return "f11"
        case kVK_F12: return "f12"
        case kVK_F13: return "f13"
        case kVK_F14: return "f14"
        case kVK_F15: return "f15"
        case kVK_F16: return "f16"
        case kVK_F17: return "f17"
        case kVK_F18: return "f18"
        case kVK_F19: return "f19"
        case kVK_F20: return "f20"
        case kVK_ANSI_Keypad0: return "numpad0"
        case kVK_ANSI_Keypad1: return "numpad1"
        case kVK_ANSI_Keypad2: return "numpad2"
        case kVK_ANSI_Keypad3: return "numpad3"
        case kVK_ANSI_Keypad4: return "numpad4"
        case kVK_ANSI_Keypad5: return "numpad5"
        case kVK_ANSI_Keypad6: return "numpad6"
        case kVK_ANSI_Keypad7: return "numpad7"
        case kVK_ANSI_Keypad8: return "numpad8"
        case kVK_ANSI_Keypad9: return "numpad9"
        case kVK_ANSI_KeypadDecimal: return "numpaddot"
        case kVK_ANSI_KeypadMultiply: return "numpadasterisk"
        case kVK_ANSI_KeypadPlus: return "numpadplus"
        case kVK_ANSI_KeypadMinus: return "numpadminus"
        case kVK_ANSI_KeypadDivide: return "numpadslash"
        case kVK_ANSI_KeypadEnter: return "numpadenter"
        case kVK_ANSI_KeypadEquals: return "numpadequal"
        default: return nil
        }
    }
}
