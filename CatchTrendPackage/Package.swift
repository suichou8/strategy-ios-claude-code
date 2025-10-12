// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CatchTrendPackage",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CatchTrendPackage",
            targets: ["CatchTrendPackage"]
        ),
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        ),
        .library(
            name: "Shared",
            targets: ["Shared"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CatchTrendPackage",
            dependencies: ["NetworkKit", "Shared"]
        ),
        .testTarget(
            name: "CatchTrendPackageTests",
            dependencies: ["CatchTrendPackage"]
        ),

        // MARK: - Shared
        .target(
            name: "Shared",
            dependencies: []
        ),
        .testTarget(
            name: "SharedTests",
            dependencies: ["Shared"]
        ),

        // MARK: - NetworkKit
        .target(
            name: "NetworkKit",
            dependencies: ["Shared"]
        ),
        // NetworkKit tests will be added in Phase 2 (when API is stable)
        // See Todos/TESTING_STRATEGY.md for details
        // .testTarget(
        //     name: "NetworkKitTests",
        //     dependencies: ["NetworkKit"]
        // ),
    ]
)
