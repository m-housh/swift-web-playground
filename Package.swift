// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "swift-web-playground",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "DatabaseClient", targets: ["DatabaseClient"]),
    .library(name: "DatabaseClientLive", targets: ["DatabaseClientLive"]),
    .library(name: "Router", targets: ["Router"]),
    .library(name: "SharedModels", targets: ["SharedModels"]),
    .library(name: "SiteMiddleware", targets: ["SiteMiddleware"]),
  ],
  dependencies: [
    .package(name: "Web", url: "https://github.com/pointfreeco/swift-web.git", .branch("main")),
    .package(name: "Prelude", url: "https://github.com/pointfreeco/swift-prelude.git", .revision("9240a1f")),
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "0.5.0"),
    .package(url: "https://github.com/vapor/postgres-kit.git", from: "2.3.0"),
  ],
  targets: [
    .target(
      name: "DatabaseClient",
      dependencies: [
        "SharedModels",
        .product(name: "Either", package: "Prelude"),
      ]),
    .target(
      name: "DatabaseClientLive",
      dependencies: [
        "SharedModels",
        "DatabaseClient",
        .product(name: "Either", package: "Prelude"),
        .product(name: "PostgresKit", package: "postgres-kit"),
      ]),
    .testTarget(
      name: "DatabaseLiveTests",
      dependencies: [
        "DatabaseClientLive"
      ]),
    .target(
      name: "Router",
      dependencies: [
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "CasePaths", package: "swift-case-paths")
      ]),
    .testTarget(
      name: "RouterTests",
      dependencies: ["Router"]
    ),
    .target(
      name: "SharedModels",
      dependencies: [
      ]),
    .target(
      name: "SiteMiddleware",
      dependencies: [
        "DatabaseClient",
        "Router",
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "HttpPipeline", package: "Web"),
//        .product(name: "Either", package: "Prelude"),
      ]),
  ]
)
