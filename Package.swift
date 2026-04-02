// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Clackable",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
        .macCatalyst(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Clackable",
            targets: ["Clackable"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Clackable",
            resources: [
                .process("Sounds (pre-installed)")
            ]
        ),
        .testTarget(
            name: "ClackableTests",
            dependencies: ["Clackable"]
        ),
    ]
)
