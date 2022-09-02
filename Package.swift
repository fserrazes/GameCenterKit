// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameCenterKit",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "GameCenterKit", targets: ["GameCenterKit"]),
    ],
    targets: [
        .target(name: "GameCenterKit", dependencies: [], path: "Sources")
    ]
)
