// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Stockee",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Stockee",
            targets: ["Stockee"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Stockee",
            dependencies: []),
        .testTarget(
            name: "StockeeTests",
            dependencies: ["Stockee"]),
    ])
