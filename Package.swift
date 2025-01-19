// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name = "ThreadsSafePropertyWrappers"
let version = "1.0.6"

let package = Package(
    name: name,
    platforms: [.macOS(.v15), .iOS(.v15), .watchOS(.v8), .tvOS(.v15)],
    products: [
        .library(
            name: name,
            targets: [name]),
    ],
    targets: [
        .target(
            name: name
        ),
        .testTarget(
            name: "\(name)Tests",
            dependencies: [.init(stringLiteral: name)]
        ),
    ]
)
