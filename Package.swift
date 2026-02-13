// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KeyPilot",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "KeyPilot",
            path: "Sources/KeyPilot"
        )
    ]
)
