import XCTest
@testable import EnvVars

final class EnvVarsTests: XCTestCase {
  
  func testCodable() {
    let envVarsDict = [
      "APP_ENV": "testing",
      "BASE_URL": "https://example.com",
      "DATABASE_URL": "postgres://example:example@example.com:5432/playground_example",
      "PORT": "443"
    ]
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let envVars = try! decoder.decode(
      EnvVars.self, from: encoder.encode(envVarsDict)
    )
    
    XCTAssertEqual(envVars.appEnv, .testing)
    XCTAssertEqual(envVars.baseUrl, URL(string: "https://example.com")!)
    XCTAssertEqual(envVars.databaseUrl, "postgres://example:example@example.com:5432/playground_example")
    XCTAssertEqual(envVars.port, "443")
    
    XCTAssertNotEqual(EnvVars(), envVars)
  }
}
