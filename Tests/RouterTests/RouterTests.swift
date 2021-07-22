import ApplicativeRouter
import Optics
import Prelude
import XCTest

@testable import CrudRouter
@testable import DatabaseClient
@testable import ServerRouter
@testable import SharedModels

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class RouterTests: XCTestCase {

  let router = ServerRouter.router(decoder: JSONDecoder(), encoder: JSONEncoder())

  func testFavoritesFetchRoute() {
    let route = ServerRoute.favorites(.fetch(nil))
    let request =
      URLRequest(url: URL(string: "favorites")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: ServerRoute.favorites(.fetch(nil))))
  }
  
  func testFavoritesFetchRouteWithUserId() {
    let userId = UUID()
    let route = ServerRoute.favorites(.fetch(userId))
    
    let request =
      URLRequest(url: URL(string: "favorites?userId=\(userId)")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: ServerRoute.favorites(.fetch(userId))))
  }

  func testUsersFetchRoute() {
    let route = ServerRoute.users(.fetch)
    let request =
      URLRequest(url: URL(string: "users")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: ServerRoute.users(.fetch)))
    XCTAssertEqual("users", router.templateUrl(for: route)?.absoluteString)
  }

  func testFavoritesFetchOneRoute() {
    let id = UUID()
    let route = ServerRoute.favorites(.default(.fetchOne(id: id)))
    let request =
      URLRequest(url: URL(string: "favorites/\(id)")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .favorites(.default(.fetchOne(id: id)))))
  }

  func testUsersFetchOneRoute() {
    let id = UUID()
    let route = ServerRoute.users(.fetchOne(id: id))
    let request =
      URLRequest(url: URL(string: "users/\(id)")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .users(.fetchOne(id: id))))
  }

  func testFavoritesInsertRoute() {
    let userId = UUID()
    let favorite = DatabaseClient.InsertFavoriteRequest(userId: userId, description: "blob")
    let route = ServerRoute.favorites(.default(.insert(favorite)))
    let request =
      URLRequest(url: URL(string: "favorites")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(favorite))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .favorites(.default(.insert(favorite)))))
  }

  func testUsersInsertRoute() {
    let user = DatabaseClient.InsertUserRequest(name: "blob")
    let route = ServerRoute.users(.insert(user))
    let request =
      URLRequest(url: URL(string: "users")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(user))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .users(.insert(user))))
  }

  func testFavoritesUpdateRoute() {
    let id = UUID()
    let update = ServerRoute.UpdateFavoriteRequest(description: "blob")
    let route = ServerRoute.favorites(.default(.update(id: id, update: update)))
    let request =
      URLRequest(url: URL(string: "favorites/\(id)")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(update))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .favorites(.default(.update(id: id, update: update)))))
  }

  func testUsersUpdateRoute() {
    let id = UUID()
    let update = ServerRoute.UpdateUserRequest(name: "blob")
    let route = ServerRoute.users(.update(id: id, update: update))
    let request =
      URLRequest(url: URL(string: "users/\(id)")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(update))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .users(.update(id: id, update: update))))
  }

  func testFavoritesDeleteRoute() {
    let id = UUID()
    let route = ServerRoute.favorites(.default(.delete(id: id)))
    let request =
      URLRequest(url: URL(string: "favorites/\(id)")!)
      |> \.httpMethod .~ "delete"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .favorites(.default(.delete(id: id)))))
  }

  func testUsersDeleteRoute() {
    let id = UUID()
    let route = ServerRoute.users(.delete(id: id))
    let request =
      URLRequest(url: URL(string: "users/\(id)")!)
      |> \.httpMethod .~ "delete"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .users(.delete(id: id))))
  }
}
