import HttpPipeline
import Foundation
import NIO
import ServerBootstrap
import SiteMiddleware

#if DEBUG
  let numberOfThreads = 1
#else
  let numberOfThreads = System.coreCount
#endif

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: numberOfThreads)

let environment = try bootstrap(eventLoopGroup: eventLoopGroup)
  .run
  .perform()
  .unwrap()

run(
  siteMiddleware(environment: environment),
  on: 8080,
  eventLoopGroup: eventLoopGroup,
  gzip: false,
  baseUrl: URL(string: "http://localhost:8080")!
)

try environment.database.shutdown()
  .run
  .perform()
  .unwrap()
