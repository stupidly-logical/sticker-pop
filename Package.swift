// swift-tools-version: 5.9
// Apps depend on this repository directly:
//   .package(url: "https://github.com/stupidly-logical/sticker-pop.git", from: "0.1.1")
// Sources live in packages/ios/StickerPop.
import PackageDescription

let package = Package(
    name: "StickerPop",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "StickerPop", targets: ["StickerPop"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0"),
    ],
    targets: [
        .target(
            name: "StickerPop",
            path: "packages/ios/StickerPop/Sources/StickerPop",
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "StickerPopDemo",
            dependencies: ["StickerPop"],
            path: "packages/ios/StickerPop/Demo"
        ),
        .testTarget(
            name: "StickerPopTests",
            dependencies: [
                "StickerPop",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            path: "packages/ios/StickerPop/Tests/StickerPopTests",
            exclude: ["__Snapshots__"]
        ),
    ]
)
