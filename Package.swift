// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StrategyiOS",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // App功能模块 - SwiftUI Views
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]
        ),
        // 安全模块 - Keychain管理
        .library(
            name: "SecurityKit",
            targets: ["SecurityKit"]
        ),
        // 网络模块 - API客户端和网络层
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        ),
        // 股票模块 - 股票数据模型和服务
        .library(
            name: "StockKit",
            targets: ["StockKit"]
        ),
    ],
    dependencies: [
        // 第三方依赖 - 按需添加
        // 图表库
        // .package(url: "https://github.com/danielgindi/Charts.git", from: "5.0.0"),

        // 网络调试
        // .package(url: "https://github.com/kean/Pulse.git", from: "4.0.0"),

        // 键盘管理
        // .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "6.5.0"),

        // 下拉刷新
        // .package(url: "https://github.com/globulus/swiftui-pull-to-refresh.git", from: "1.0.0")
    ],
    targets: [
        // MARK: - AppFeature
        .target(
            name: "AppFeature",
            dependencies: [
                "StockKit"
            ],
            resources: [
                .process("Assets.xcassets")
            ]
        ),

        // MARK: - SecurityKit
        .target(
            name: "SecurityKit",
            dependencies: []
        ),
        .testTarget(
            name: "SecurityKitTests",
            dependencies: ["SecurityKit"]
        ),

        // MARK: - NetworkKit
        .target(
            name: "NetworkKit",
            dependencies: [
                "SecurityKit"
            ]
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: ["NetworkKit", "SecurityKit"]
        ),

        // MARK: - StockKit
        .target(
            name: "StockKit",
            dependencies: [
                "NetworkKit",
                "SecurityKit"
            ]
        ),
        .testTarget(
            name: "StockKitTests",
            dependencies: ["StockKit", "NetworkKit", "SecurityKit"]
        ),
    ]
)
