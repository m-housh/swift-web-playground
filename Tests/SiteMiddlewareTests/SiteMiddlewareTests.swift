import XCTest
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
import HttpPipeline
import HttpPipelineTestSupport
import SharedModels
import ServerRouter
import SnapshotTesting
import EnvVars

@testable import SiteMiddleware

class SiteMiddlewareTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  func testHappyPath() {
    var request = URLRequest(url: URL(string: "/api/users")!)
    request.httpMethod = "GET"
    
    var environment = ServerEnvironment.failing
    let userId = UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!
    environment.database.users.fetch = { .init(value: [User(id: userId, name: "blob")]) }
    
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    GET /api/users
    
    200 OK
    Content-Length: 82
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block

    [
      {
        "id" : "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF",
        "name" : "blob"
      }
    ]
    """#)
  }
  
  func testUnhappyPath() {
    var request = URLRequest(url: URL(string: "/api/not-available")!)
    request.httpMethod = "GET"
    let environment = ServerEnvironment.failing
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    GET /api/not-available
    
    404 Not Found
    Content-Length: 2
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block

    {}
    """#)
  }
  
  func testResponseWhenDatabaseThrowsError() {
    struct TestError: Error {}
    var request = URLRequest(url: URL(string: "/api/users")!)
    request.httpMethod = "get"
    var environment = ServerEnvironment.failing
    environment.database.users.fetch = { .init(run: .init { .left(TestError()) }) }
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    GET /api/users
    
    500 Internal Server Error
    Content-Length: 145
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block

    {
      "errorDump" : "Testing error.",
      "file" : "SiteMiddleware\/Middleware.swift",
      "line" : 147,
      "message" : "This is an error for testing"
    }
    """#)
  }
  
  func testResponseWhenDatabaseThrowsErrorOnVoidValue() {
    struct TestError: Error {}
    var request = URLRequest(url: URL(string: "/api/users/\(User.blob.id)")!)
    request.httpMethod = "delete"
    var environment = ServerEnvironment.failing
    environment.database.users.delete = { _ in .init(run: .init { .left(TestError()) }) }
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    DELETE /api/users/DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF
    
    500 Internal Server Error
    Content-Length: 145
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block

    {
      "errorDump" : "Testing error.",
      "file" : "SiteMiddleware\/Middleware.swift",
      "line" : 171,
      "message" : "This is an error for testing"
    }
    """#)
  }
}
