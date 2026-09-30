// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_wallet_card",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "flutter-wallet-card", targets: ["flutter_wallet_card"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/krzyzanowskim/OpenSSL-Package.git",
            .upToNextMajor(from: "3.6.1")),
    ],
    targets: [
        .target(
            name: "flutter_wallet_card",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "OpenSSL", package: "OpenSSL-Package"),
            ],
            resources: []
        )
    ]
)
