import HttpPipeline
import Foundation
import Logging
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

var logger = Logger(label: "web.playground")
logger.logLevel = .debug

run(
  siteMiddleware(environment: environment, logger: logger),
  on: Int(environment.envVars.port) ?? 8080,
  eventLoopGroup: eventLoopGroup,
  gzip: false,
  baseUrl: environment.envVars.baseUrl
)

try environment.database.shutdown()
  .run
  .perform()
  .unwrap()
