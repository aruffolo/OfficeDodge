// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "OfficeDodge",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "OfficeDodgeCore", targets: ["OfficeDodgeCore"]),
    ],
    targets: [
        .target(
            name: "OfficeDodgeCore",
            path: "Sources/OfficeDodgeCore"
        ),
        .target(
            name: "AppFeature",
            dependencies: ["OfficeDodgeCore"],
            path: "Sources/OfficeDodgeAppFeature"
        ),
        .testTarget(
            name: "OfficeDodgeCoreTests",
            dependencies: ["OfficeDodgeCore"],
            path: "Tests/OfficeDodgeCoreTests"
        ),
    ]
)
