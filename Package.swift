// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "swift-markdown-ui",
  platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .macCatalyst(.v16),
        .watchOS(.v9),
    ],
  products: [
    .library(
      name: "MarkdownUI",
      targets: ["MarkdownUI"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/gonzalezreal/NetworkImage", from: "6.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.10.0"),
    .package(url: "https://github.com/lindsaycharlotte2023/swift-markdown.git", branch: "latex"),
    .package(url: "https://github.com/lindsaycharlotte2023/LaTeXSwiftUI.git", branch: "latex"),
//        .package(path: "lib/swift-markdown"),
//        .package(path: "lib/LaTeXSwiftUI"),
  ],
  targets: [
    .target(
        name: "_Parser",
        dependencies: [
            .product(name: "Markdown", package: "swift-markdown"),
            .product(name: "LaTeXSwiftUI", package: "LaTeXSwiftUI"),
        ]
    ),
    .target(
      name: "MarkdownUI",
      dependencies: [
        "_Parser",
        .product(name: "NetworkImage", package: "NetworkImage"),
      ]
    ),
    .testTarget(
      name: "MarkdownUITests",
      dependencies: [
        "MarkdownUI",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: ["__Snapshots__"]
    ),
  ]
)
