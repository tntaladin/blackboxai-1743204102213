// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "UberClone",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "UberClone",
            targets: ["UberClone"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "UberClone",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ]),
        .testTarget(
            name: "UberCloneTests",
            dependencies: ["UberClone"]),
    ]
)