// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "caffeinate-downloads",
    platforms: [.macOS(.v13)],
    dependencies: [
      .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.0"),
      .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
      .package(url: "https://github.com/apple/swift-nio.git", from: "2.88.0"),
      .package(url: "https://github.com/apple/swift-system.git", from: "1.6.0"),
      .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.9.0"),
    ],
    targets: [
      .executableTarget(
        name: "caffeinate-downloads",
        dependencies: [
          .product(name: "ArgumentParser", package: "swift-argument-parser"),
          .product(name: "Logging", package: "swift-log"),
          .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
          .product(name: "SystemPackage", package: "swift-system"),
          .product(name: "_NIOFileSystem", package: "swift-nio"),
        ]
      )
    ]
)
