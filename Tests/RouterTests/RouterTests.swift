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
  
//  let router: Router<UserRoute> = crudRouter("api", "v1", "users", id: .uuid)
  let router = ServerRouter.router(decoder: JSONDecoder(), encoder: JSONEncoder())
  
  func test_CRUDRouter_fetch() {
    let route = ServerRoute.users(UserRoute.fetch)
    let request = URLRequest(url: URL(string: "users")!)
      |> \.httpMethod .~ "get"
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: ServerRoute.users(.fetch)))
    XCTAssertEqual("users", router.templateUrl(for: route)?.absoluteString)
  }
  
  func test_CRUDRouter_fetchOne() {
    let id = UUID()
    let route = ServerRoute.users(.fetchOne(id: id))
    let request = URLRequest(url: URL(string: "users/\(id)")!)
      |> \.httpMethod .~ "get"

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .users(.fetchOne(id: id))))
  }

  func test_CRUDRouter_insert() {
    let user = DatabaseClient.InsertUserRequest(name: "blob")
    let route = ServerRoute.users(.insert(user))
    let request = URLRequest(url: URL(string: "users")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(user))

    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .users(.insert(user))))
  }

  func test_CRUDRouter_update() {
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
}
