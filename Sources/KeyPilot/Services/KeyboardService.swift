import Foundation

actor KeyboardService {
    private let toolPath: String

    enum KeyboardError: Error, LocalizedError {
        case toolNotFound(String)
        case uploadFailed(exitCode: Int32, stderr: String)
        case deviceNotConnected

        var errorDescription: String? {
            switch self {
            case .toolNotFound(let path):
                return "ch57x-keyboard-tool not found at: \(path)"
            case .uploadFailed(let code, let stderr):
                return "Upload failed (exit \(code)): \(stderr)"
            case .deviceNotConnected:
                return "Keyboard not connected"
            }
        }
    }

    init(toolPath: String? = nil) {
        if let toolPath {
            self.toolPath = toolPath
        } else {
            // Look in common locations
            let candidates = [
                NSString(string: "~/.cargo/bin/ch57x-keyboard-tool")
                    .expandingTildeInPath,
                "/usr/local/bin/ch57x-keyboard-tool",
                "/opt/homebrew/bin/ch57x-keyboard-tool",
            ]
            self.toolPath =
                candidates.first { FileManager.default.isExecutableFile(atPath: $0) }
                ?? candidates[0]
        }
    }

    func upload(profile: Profile) async throws {
        guard FileManager.default.isExecutableFile(atPath: toolPath) else {
            throw KeyboardError.toolNotFound(toolPath)
        }

        let yaml = YAMLGenerator.generate(from: profile.keyMapping)

        let tempURL =
            FileManager.default.temporaryDirectory
            .appendingPathComponent("keypilot-\(UUID().uuidString).yaml")
        try yaml.write(to: tempURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        process.arguments = ["upload", tempURL.path]

        let stderrPipe = Pipe()
        let stdoutPipe = Pipe()
        process.standardError = stderrPipe
        process.standardOutput = stdoutPipe

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
            let stderr = String(data: stderrData, encoding: .utf8) ?? ""

            if stderr.lowercased().contains("no device")
                || stderr.lowercased().contains("not found")
                || stderr.lowercased().contains("usb")
            {
                throw KeyboardError.deviceNotConnected
            }

            throw KeyboardError.uploadFailed(
                exitCode: process.terminationStatus, stderr: stderr
            )
        }
    }

    func validate(profile: Profile) async throws -> Bool {
        guard FileManager.default.isExecutableFile(atPath: toolPath) else {
            throw KeyboardError.toolNotFound(toolPath)
        }

        let yaml = YAMLGenerator.generate(from: profile.keyMapping)

        let tempURL =
            FileManager.default.temporaryDirectory
            .appendingPathComponent("keypilot-validate-\(UUID().uuidString).yaml")
        try yaml.write(to: tempURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        process.arguments = ["validate", tempURL.path]

        let stderrPipe = Pipe()
        process.standardError = stderrPipe
        process.standardOutput = Pipe()

        try process.run()
        process.waitUntilExit()

        return process.terminationStatus == 0
    }
}
