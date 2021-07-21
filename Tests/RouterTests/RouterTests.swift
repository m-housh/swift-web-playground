import ApplicativeRouter
import XCTest
import Prelude
import Optics
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@testable import DatabaseClient
@testable import CrudRouter
@testable import ServerRouter
@testable import SharedModels

final class RouterTests: XCTestCase {
  
  let router = ServerRouter.router(decoder: JSONDecoder(), encoder: JSONEncoder())
  
  func testFavoritesFetchRoute() {
    let route = ServerRoute.favorites(.fetch)
    let request = URLRequest(url: URL(string: "favorites")!)
      |> \.httpMethod .~ "get"
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: ServerRoute.favorites(.fetch)))
    XCTAssertEqual("favorites", router.templateUrl(for: route)?.absoluteString)
  }
  
  func testUsersFetchRoute() {
    let route = ServerRoute.users(.fetch)
    let request = URLRequest(url: URL(string: "users")!)
      |> \.httpMethod .~ "get"
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: ServerRoute.users(.fetch)))
    XCTAssertEqual("users", router.templateUrl(for: route)?.absoluteString)
  }
  
  func testFavoritesFetchOneRoute() {
    let id = UUID()
    let route = ServerRoute.favorites(.fetchOne(id: id))
    let request = URLRequest(url: URL(string: "favorites/\(id)")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .favorites(.fetchOne(id: id))))
  }
  
  func testUsersFetchOneRoute() {
    let id = UUID()
    let route = ServerRoute.users(.fetchOne(id: id))
    let request = URLRequest(url: URL(string: "users/\(id)")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .users(.fetchOne(id: id))))
  }
  
  func testFavoritesInsertRoute() {
    let userId = UUID()
    let favorite = DatabaseClient.InsertFavoriteRequest(userId: userId, description: "blob")
    let route = ServerRoute.favorites(.insert(favorite))
    let request = URLRequest(url: URL(string: "favorites")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(favorite))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .favorites(.insert(favorite))))
  }

  func testUsersInsertRoute() {
    let user = DatabaseClient.InsertUserRequest(name: "blob")
    let route = ServerRoute.users(.insert(user))
    let request = URLRequest(url: URL(string: "users")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(user))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .users(.insert(user))))
  }
  
  func testFavoritesUpdateRoute() {
    let id = UUID()
    let update = DatabaseClient.UpdateFavoriteRequest(id: id, description: "blob")
    let route = ServerRoute.favorites(.update(id: id, update: update))
    let request = URLRequest(url: URL(string: "favorites/\(id)")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(update))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .favorites(.update(id: id, update: update))))
  }

  func testUsersUpdateRoute() {
    let id = UUID()
    let update = DatabaseClient.UpdateUserRequest(id: id, name: "blob")
    let route = ServerRoute.users(.update(id: id, update: update))
    let request = URLRequest(url: URL(string: "users/\(id)")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(update))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .users(.update(id: id, update: update))))
  }
  
  func testFavoritesDeleteRoute() {
    let id = UUID()
    let route = ServerRoute.favorites(.delete(id: id))
    let request = URLRequest(url: URL(string: "favorites/\(id)")!)
      |> \.httpMethod .~ "delete"
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .favorites(.delete(id: id))))
  }
  
  func testUsersDeleteRoute() {
    let id = UUID()
    let route = ServerRoute.users(.delete(id: id))
    let request = URLRequest(url: URL(string: "users/\(id)")!)
      |> \.httpMethod .~ "delete"
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .users(.delete(id: id))))
  }
}
