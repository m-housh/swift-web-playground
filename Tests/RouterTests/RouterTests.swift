import ApplicativeRouter
import XCTest
import Prelude
import Optics
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@testable import CrudRouter
@testable import ServerRouter
@testable import SharedModels

final class RouterTests: XCTestCase {
  
  typealias Route = CRUDRoute<User, InsertUserRequest, UpdateUserRequest>
  let router: Router<Route> = crudRouter("api", "v1", "users", id: .uuid)
  
  func test_CRUDRouter_fetch() {
    let route = Route.fetch
    let request = URLRequest(url: URL(string: "api/v1/users")!)
      |> \.httpMethod .~ "get"
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .fetch))
    XCTAssertEqual("api/v1/users", router.templateUrl(for: route)?.absoluteString)
  }
  
  func test_CRUDRouter_fetchOne() {
    let id = UUID()
    let route = Route.fetchOne(id: id)
    let request = URLRequest(url: URL(string: "api/v1/users/\(id)")!)
      |> \.httpMethod .~ "get"
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .fetchOne(id: id)))
  }
  
  func test_CRUDRouter_insert() {
    let user = InsertUserRequest(name: "blob")
    let route = Route.insert(user)
    let request = URLRequest(url: URL(string: "api/v1/users")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(user))
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .insert(user)))
  }
  
  func test_CRUDRouter_update() {
    let id = UUID()
    let update = UpdateUserRequest(name: "blob")
    let route = Route.update(id: id, update: update)
    let request = URLRequest(url: URL(string: "api/v1/users/\(id)")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(update))
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .update(id: id, update: update)))
  }
}
