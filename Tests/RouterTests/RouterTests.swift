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

  let router = ServerRouter.router(
    pathPrefix: .init("api"),
    decoder: JSONDecoder(),
    encoder: JSONEncoder()
  )

  func testFavoritesFetchRoute() {
    let route = ApiRoute.favorites(.fetch(userId: nil))
    let request =
      URLRequest(url: URL(string: "api/favorites")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: ApiRoute.favorites(.fetch(userId: nil))))
  }
  
  func testFavoritesFetchRouteWithUserId() {
    let userId = UUID()
    let route = ApiRoute.favorites(.fetch(userId: userId))
    
    let request =
      URLRequest(url: URL(string: "api/favorites?userId=\(userId)")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: ApiRoute.favorites(.fetch(userId: userId))))
  }

  func testUsersFetchRoute() {
    let route = ApiRoute.users(.fetch)
    let request =
      URLRequest(url: URL(string: "api/users")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: ApiRoute.users(.fetch)))
    XCTAssertEqual("api/users", router.templateUrl(for: route)?.absoluteString)
  }

  func testFavoritesFetchOneRoute() {
    let id = UUID()
    let route = ApiRoute.favorites(.fetchId(id: id))
    let request =
      URLRequest(url: URL(string: "api/favorites/\(id)")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .favorites(.fetchId(id: id))))
  }

  func testUsersFetchOneRoute() {
    let id = UUID()
    let route = ApiRoute.users(.fetchId(id: id))
    let request =
      URLRequest(url: URL(string: "api/users/\(id)")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .users(.fetchId(id: id))))
  }

  func testFavoritesInsertRoute() {
    let userId = UUID()
    let favorite = ApiRoute.FavoritesRoute.InsertRequest(description: "blob", userId: userId)
    let route = ApiRoute.favorites(.insert(favorite))
    let request =
      URLRequest(url: URL(string: "api/favorites")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(favorite))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .favorites(.insert(favorite))))
  }

  func testUsersInsertRoute() {
    let user = ApiRoute.UsersRoute.InsertRequest(name: "blob")
    let route = ApiRoute.users(.insert(user))
    let request =
      URLRequest(url: URL(string: "api/users")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(user))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .users(.insert(user))))
  }

  func testFavoritesUpdateRoute() {
    let id = UUID()
    let update = ApiRoute.FavoritesRoute.UpdateRequest(description: "blob")
    let route = ApiRoute.favorites(.update(id: id, update: update))
    let request =
      URLRequest(url: URL(string: "api/favorites/\(id)")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(update))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .favorites(.update(id: id, update: update))))
  }

  func testUsersUpdateRoute() {
    let id = UUID()
    let update = ApiRoute.UsersRoute.UpdateRequest(name: "blob")
    let route = ApiRoute.users(.update(id: id, update: update))
    let request =
      URLRequest(url: URL(string: "api/users/\(id)")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(update))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .users(.update(id: id, update: update))))
  }

  func testFavoritesDeleteRoute() {
    let id = UUID()
    let route = ApiRoute.favorites(.delete(id: id))
    let request =
      URLRequest(url: URL(string: "api/favorites/\(id)")!)
      |> \.httpMethod .~ "delete"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .favorites(.delete(id: id))))
  }

  func testUsersDeleteRoute() {
    let id = UUID()
    let route = ApiRoute.users(.delete(id: id))
    let request =
      URLRequest(url: URL(string: "api/users/\(id)")!)
      |> \.httpMethod .~ "delete"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .users(.delete(id: id))))
  }
}
