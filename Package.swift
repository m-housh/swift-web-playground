// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "swift-web-playground",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "CrudRouter", targets: ["CrudRouter"]),
    .library(name: "DatabaseClient", targets: ["DatabaseClient"]),
    .library(name: "DatabaseClientLive", targets: ["DatabaseClientLive"]),
    .library(name: "EnvVars", targets: ["EnvVars"]),
    .library(name: "ServerRouter", targets: ["ServerRouter"]),
    .executable(name: "server", targets: ["server"]),
    .library(name: "ServerBootstrap", targets: ["ServerBootstrap"]),
    .library(name: "SharedModels", targets: ["SharedModels"]),
    .library(name: "SiteMiddleware", targets: ["SiteMiddleware"]),
  ],
  dependencies: [
    .package(name: "Web", url: "https://github.com/pointfreeco/swift-web.git", .revision("616f365")),
    .package(name: "Prelude", url: "https://github.com/pointfreeco/swift-prelude.git", .revision("9240a1f")),
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "0.5.0"),
    .package(url: "https://github.com/vapor/postgres-kit.git", from: "2.3.0"),
  ],
  targets: [
    .target(
      name: "CrudRouter",
      dependencies: [
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "CasePaths", package: "swift-case-paths")
      ]),
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
      name: "EnvVars",
      dependencies: []),
    .target(
      name: "server",
      dependencies: [
        "ServerBootstrap",
        "SiteMiddleware",
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "CasePaths", package: "swift-case-paths")
      ]),
    .target(
      name: "ServerBootstrap",
      dependencies: [
        "DatabaseClientLive",
        "EnvVars",
        "ServerRouter",
        "SiteMiddleware",
        .product(name: "Either", package: "Prelude")
      ]),
    .target(
      name: "ServerRouter",
      dependencies: [
        "SharedModels",
        "CrudRouter",
        "DatabaseClient", // TODO: Remove this dependency if possible
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "CasePaths", package: "swift-case-paths")
      ]),
    .testTarget(
      name: "RouterTests",
      dependencies: [
        "ServerRouter",
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "CasePaths", package: "swift-case-paths")
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
//        .product(name: "Either", package: "Prelude"),
      ]),
  ]
)
