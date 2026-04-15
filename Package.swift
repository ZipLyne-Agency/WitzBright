// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WitzLyte",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "WitzLyte",
            path: "Sources/WitzLyte"
        )
    ]
)
