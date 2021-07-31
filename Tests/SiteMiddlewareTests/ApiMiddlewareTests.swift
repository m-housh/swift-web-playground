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
import SiteMiddleware

class ApiMiddlewareTests: XCTestCase {
  
  func testUsersFetchRoute() {
    var request = URLRequest(url: URL(string: "/api/users")!)
    request.httpMethod = "get"
    var environment = ServerEnvironment.failing
    environment.database.users.fetch = { .init(value: [.blob, .blobJr, .blobSr]) }
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    GET /api/users
    
    200 OK
    Content-Length: 248
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block

    [
      {
        "id" : "DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF",
        "name" : "blob"
      },
      {
        "id" : "DEADBEEF-0002-BEEF-DEAD-BEEFDEADBEEF",
        "name" : "blob-jr"
      },
      {
        "id" : "DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF",
        "name" : "blob-sr"
      }
    ]
    """#)
  }
  
  func testUsersFetchIdRoute() {
    var request = URLRequest(url: URL(string: "/api/users/\(User.blob.id)")!)
    request.httpMethod = "get"
    var environment = ServerEnvironment.failing
    environment.database.users.fetchId = { _ in .init(value: .blob) }
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    GET /api/users/DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF
    
    200 OK
    Content-Length: 70
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block

    {
      "id" : "DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF",
      "name" : "blob"
    }
    """#)
  }
  
  func testUsersInsertRoute() {
    var request = URLRequest(url: URL(string: "/api/users")!)
    request.httpMethod = "post"
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    request.httpBody = try! encoder.encode(User.blobJr)
    var environment = ServerEnvironment.failing
    environment.database.users.insert = { _ in .init(value: .blobJr) }
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    POST /api/users

    {"id":"DEADBEEF-0002-BEEF-DEAD-BEEFDEADBEEF","name":"blob-jr"}

    200 OK
    Content-Length: 73
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block

    {
      "id" : "DEADBEEF-0002-BEEF-DEAD-BEEFDEADBEEF",
      "name" : "blob-jr"
    }
    """#)
  }
  
  func testUsersUpdateRoute() {
    var request = URLRequest(url: URL(string: "/api/users/\(User.blobSr.id)")!)
    request.httpMethod = "post"
    request.httpBody = try! JSONEncoder().encode(["name": "updated-blob-sr"])
    var environment = ServerEnvironment.failing
    environment.database.users.update = {  _ in .init(value: .init(id: User.blobSr.id, name: "updated-blob-sr")) }
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    POST /api/users/DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF

    {"name":"updated-blob-sr"}

    200 OK
    Content-Length: 81
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block

    {
      "id" : "DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF",
      "name" : "updated-blob-sr"
    }
    """#)
  }
  
  func testUsersDeleteRoute() {
    var request = URLRequest(url: URL(string: "/api/users/\(User.blobSr.id)")!)
    request.httpMethod = "delete"
    var environment = ServerEnvironment.failing
    environment.database.users.delete = { _ in .init(value: ()) }
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    DELETE /api/users/DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF

    200 OK
    Content-Length: 2
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    
    ""
    """#)
  }
  
  func testFavoritesFetchRoute() {
    var request = URLRequest(url: URL(string: "/api/favorites")!)
    request.httpMethod = "get"
    var environment = ServerEnvironment.failing
    environment.database.favorites.fetch = { _ in .init(value: .blobsFavorites) }
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    GET /api/favorites
    
    200 OK
    Content-Length: 289
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block

    [
      {
        "description" : "pizza",
        "id" : "DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF",
        "userId" : "DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF"
      },
      {
        "description" : "coffee",
        "id" : "DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF",
        "userId" : "DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF"
      }
    ]
    """#)
  }
  
  func testFavoritesFetchIdRoute() {
    var request = URLRequest(url: URL(string: "/api/favorites/\(UserFavorite.tacos(userId: User.blob.id).id)")!)
    request.httpMethod = "get"
    var environment = ServerEnvironment.failing
    environment.database.favorites.fetchId = { _ in .init(value: .tacos(userId: User.blob.id)) }
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    GET /api/favorites/DEADBEEF-0002-BEEF-DEAD-BEEFDEADBEEF
    
    200 OK
    Content-Length: 131
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block

    {
      "description" : "tacos",
      "id" : "DEADBEEF-0002-BEEF-DEAD-BEEFDEADBEEF",
      "userId" : "DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF"
    }
    """#)
  }
  
  func testFavoritesInsertRoute() {
    var request = URLRequest(url: URL(string: "/api/favorites")!)
    request.httpMethod = "post"
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    request.httpBody = try! encoder.encode(UserFavorite.coffee(userId: User.blobSr.id))
    var environment = ServerEnvironment.failing
    environment.database.favorites.insert = { _ in .init(value: .coffee(userId: User.blobSr.id)) }
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    POST /api/favorites

    {"description":"coffee","id":"DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF","userId":"DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF"}

    200 OK
    Content-Length: 132
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block

    {
      "description" : "coffee",
      "id" : "DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF",
      "userId" : "DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF"
    }
    """#)
  }
  
  func testFavoritesUpdateRoute() {
    var request = URLRequest(url: URL(string: "/api/favorites/DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF")!)
    request.httpMethod = "post"
    request.httpBody = try! JSONEncoder().encode(["description": "updated-pizza"])
    var environment = ServerEnvironment.failing
    environment.database.favorites.update = {  _ in
      .init(value: .init(
        id: UUID(uuidString: "DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF")!,
        userId: User.blobSr.id,
        description: "updated-pizza"
      ))
    }
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    POST /api/favorites/DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF

    {"description":"updated-pizza"}

    200 OK
    Content-Length: 139
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block

    {
      "description" : "updated-pizza",
      "id" : "DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF",
      "userId" : "DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF"
    }
    """#)
  }
  
  func testFavoritesDeleteRoute() {
    var request = URLRequest(url: URL(string: "/api/favorites/DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF")!)
    request.httpMethod = "delete"
    var environment = ServerEnvironment.failing
    environment.database.favorites.delete = { _ in .init(value: ()) }
    let middleware = siteMiddleware(environment: environment)
    let response = middleware(connection(from: request)).perform()
    
    _assertInlineSnapshot(matching: response, as: .conn, with: #"""
    DELETE /api/favorites/DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF

    200 OK
    Content-Length: 2
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    
    ""
    """#)
  }
}
