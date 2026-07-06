// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "flutter_wallet_card",
  platforms: [
    .iOS("13.0"),
  ],
  products: [
    .library(name: "flutter-wallet-card", targets: ["flutter_wallet_card"]),
  ],
  dependencies: [
    .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", from: "3.6.2000"),
  ],
  targets: [
    .target(
      name: "flutter_wallet_card",
      dependencies: [
        .product(name: "OpenSSL", package: "OpenSSL"),
      ]
    ),
  ]
)
