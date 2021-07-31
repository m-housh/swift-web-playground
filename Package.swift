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
    .library(name: "DatabaseCrudHelpers", targets: ["DatabaseCrudHelpers"]),
    .library(name: "EnvVars", targets: ["EnvVars"]),
    .library(name: "RouterUtils", targets: ["RouterUtils"]),
    .library(name: "ServerBootstrap", targets: ["ServerBootstrap"]),
    .library(name: "ServerRouter", targets: ["ServerRouter"]),
    .library(name: "ServerTestHelpers", targets: ["ServerTestHelpers"]),
    .executable(name: "server", targets: ["server"]),
    .library(name: "SharedModels", targets: ["SharedModels"]),
    .library(name: "SiteMiddleware", targets: ["SiteMiddleware"]),
  ],
  dependencies: [
    .package(
      name: "Web", url: "https://github.com/pointfreeco/swift-web.git", .revision("616f365")),
    .package(
      name: "Prelude", url: "https://github.com/pointfreeco/swift-prelude.git", .revision("9240a1f")
    ),
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "0.5.0"),
    .package(url: "https://github.com/vapor/postgres-kit.git", from: "2.3.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty.git", from: "0.3.1"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git", from: "0.1.0"),
    .package(
      name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .exact("1.8.2")
    ),
  ],
  targets: [
    .target(
      name: "DatabaseClient",
      dependencies: [
        "ServerTestHelpers",
        "SharedModels",
        .product(name: "Either", package: "Prelude"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]),
    .target(
      name: "DatabaseClientLive",
      dependencies: [
        "SharedModels",
        "DatabaseClient",
        "DatabaseCrudHelpers",
        .product(name: "Either", package: "Prelude"),
        .product(name: "PostgresKit", package: "postgres-kit"),
      ]),
    .testTarget(
      name: "DatabaseLiveTests",
      dependencies: [
        "DatabaseClientLive"
      ]),
    .target(
      name: "DatabaseCrudHelpers",
      dependencies: [
        .product(name: "Either", package: "Prelude"),
        .product(name: "PostgresKit", package: "postgres-kit"),
        .product(name: "NonEmpty", package: "swift-nonempty"),
      ]),
    .target(
      name: "EnvVars",
      dependencies: []),
    .testTarget(
      name: "EnvVarsTests",
      dependencies: ["EnvVars"]),
    .target(
      name: "RouterUtils",
      dependencies: [
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "NonEmpty", package: "swift-nonempty"),
      ]),
    .testTarget(
      name: "RouterUtilsTests",
      dependencies: ["RouterUtils"]
    ),
    .target(
      name: "server",
      dependencies: [
        "ServerBootstrap",
        "SiteMiddleware",
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "CasePaths", package: "swift-case-paths"),
      ]),
    .target(
      name: "ServerBootstrap",
      dependencies: [
        "DatabaseClientLive",
        "EnvVars",
        "ServerRouter",
        "SiteMiddleware",
        .product(name: "Either", package: "Prelude"),
      ]),
    .target(
      name: "ServerRouter",
      dependencies: [
        "SharedModels",
        "RouterUtils",
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "NonEmpty", package: "swift-nonempty"),
      ]),
    .testTarget(
      name: "ServerRouterTests",
      dependencies: [
        "ServerRouter",
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "CasePaths", package: "swift-case-paths"),
      ]),
    .target(
      name: "ServerTestHelpers",
      dependencies: [
        .product(name: "Either", package: "Prelude"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
      ]),
    .target(
      name: "SharedModels",
      dependencies: [

      ]),
    .target(
      name: "SiteMiddleware",
      dependencies: [
        "DatabaseClient",
        "EnvVars",
        "ServerRouter",
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "ApplicativeRouterHttpPipelineSupport", package: "Web"),
        .product(name: "HttpPipeline", package: "Web"),
        .product(name: "Logging", package: "swift-log"),
      ]),
    .testTarget(
      name: "SiteMiddlewareTests",
      dependencies: [
        "SiteMiddleware",
        .product(name: "HttpPipelineTestSupport", package: "Web"),
        .product(name: "SnapshotTesting", package: "SnapshotTesting")
      ])
  ]
)
