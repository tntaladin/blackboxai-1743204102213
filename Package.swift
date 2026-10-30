// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UberCore",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "UberCore", targets: ["UberCore"])],
    targets: [
        .target(name: "UberCore", path: "Core"),
        .testTarget(name: "UberCoreTests", dependencies: ["UberCore"], path: "Tests/UberCoreTests")
    ]
)
