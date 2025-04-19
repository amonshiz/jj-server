// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-jj-mcp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "JJServer",
            targets: ["JJServer"]
        ),
        .library(
            name: "JJServerCore",
            targets: ["JJServerCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", exact: "0.7.1"),
        .package(url: "https://github.com/chrisaljoudi/swift-log-oslog.git", from: "0.2.1")
    ],
    targets: [
        .executableTarget(
            name: "JJServer",
            dependencies: [
                "JJServerCore",
                .product(name: "MCP", package: "swift-sdk"),
                .product(name: "LoggingOSLog", package: "swift-log-oslog")
            ],
            path: "Sources/JJServer"
        ),
        .target(
            name: "JJServerCore",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk"),
                .product(name: "LoggingOSLog", package: "swift-log-oslog")
            ],
            path: "Sources/JJServerCore"
        ),
        .testTarget(
            name: "JJServerTests",
            dependencies: [
                "JJServer",
                "JJServerCore",
                .product(name: "MCP", package: "swift-sdk"),
                .product(name: "LoggingOSLog", package: "swift-log-oslog")
            ],
            path: "Tests"
        )
    ]
)
