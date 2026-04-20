// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TileBasedGame",
    platforms: [
      .macOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TileBasedGame",
            targets: ["TileBasedGame"]
        ),
    ],
    dependencies: [
      .package(path: "../GameConfiguration"),
      .package(path: "../lecs-swift")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TileBasedGame",
            dependencies:["GameConfiguration", "lecs-swift"]
        ),
        .testTarget(
            name: "TileBasedGameTests",
            dependencies: [
              "GameConfiguration",
              "lecs-swift",
              "TileBasedGame"
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
