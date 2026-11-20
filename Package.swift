// swift-tools-version: 6.4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TupleKit",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "TupleKit",
      targets: ["TupleKit"]
    ),
    .library(
      name: "TupleKitComposition",
      targets: ["TupleKitComposition"]
    ),
  ],
  dependencies: [
    // Used by the snapshot test target, not by the library products.
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.7")
  ],
  targets: [
    .executableTarget(
      name: "TupleKitClient",
      dependencies: ["TupleKit"]
    ),
    .target(
      name: "TupleKit"
    ),
    .target(
      name: "TupleKitComposition"
    ),
    .testTarget(
      name: "TupleKitTests",
      dependencies: ["TupleKit"]
    ),
    .testTarget(
      name: "TupleKitCompositionTests",
      dependencies: ["TupleKit", "TupleKitComposition"]
    ),
    .testTarget(
      name: "TupleKitSnapshotTests",
      dependencies: [
        "TupleKit",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: ["__Snapshots__"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
