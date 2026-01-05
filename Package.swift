// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RiseSet",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "RiseSet", targets: ["RiseSet"])
    ],
    dependencies: [
        .package(url: "https://github.com/ceeK/Solar.git", from: "3.0.0")
    ],
    targets: [
        .executableTarget(
            name: "RiseSet",
            dependencies: ["Solar"],
            path: "RiseSet"
        )
    ]
)
