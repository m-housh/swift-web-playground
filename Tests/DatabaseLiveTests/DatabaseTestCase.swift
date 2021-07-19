import XCTest
import DatabaseClient
import DatabaseClientLive
import PostgresKit

class DatabaseTestCase: XCTestCase {
  var database: DatabaseClient!
  var pool: EventLoopGroupConnectionPool<PostgresConnectionSource>!
  let eventLoopGroup = MultiThreadedEventLoopGroup.init(numberOfThreads: 1)
  
  override func setUp() {
    super.setUp()
    
    self.pool = EventLoopGroupConnectionPool(
      source: PostgresConnectionSource(
        configuration: PostgresConfiguration(url: "postgres://playground:playground@localhost:5432/playground_test")!
      ),
      on: eventLoopGroup
    )
    
    self.database = DatabaseClient.live(pool: self.pool)
    
    try! self.database.resetForTesting(pool: pool)
  }
  
  override func tearDown() {
    super.tearDown()
    try! self.pool.syncShutdownGracefully()
    try! self.eventLoopGroup.syncShutdownGracefully()
  }
}
