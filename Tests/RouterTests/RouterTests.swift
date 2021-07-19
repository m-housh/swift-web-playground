import ApplicativeRouter
import XCTest
import Prelude
import Optics
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
@testable import Router

final class RouterTests: XCTestCase {
  
  typealias Route = CRUDRoute<User, InsertUser, User>
  let router: Router<Route> = crudRouter("users", id: .uuid)
  
  func test_CRUDRouter_fetch() {
    let route = Route.fetch
    let request = URLRequest(url: URL(string: "users")!)
      |> \.httpMethod .~ "get"
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .fetch))
    XCTAssertEqual("users", router.templateUrl(for: route)?.absoluteString)
  }
  
  func test_CRUDRouter_fetchOne() {
    let id = UUID()
    let route = Route.fetchOne(id: id)
    let request = URLRequest(url: URL(string: "users/\(id)")!)
      |> \.httpMethod .~ "get"
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .fetchOne(id: id)))
  }
  
  func test_CRUDRouter_insert() {
    let user = InsertUser(name: "blob")
    let route = Route.insert(user)
    let request = URLRequest(url: URL(string: "users")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(user))
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .insert(user)))
  }
  
  func test_CRUDRouter_update() {
    let user = User(id: .init(), name: "blob")
    let route = Route.update(id: user.id, update: user)
    let request = URLRequest(url: URL(string: "users/\(user.id)")!)
      |> \.httpMethod .~ "post"
      |> \.httpBody .~ (try? JSONEncoder().encode(user))
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: .update(id: user.id, update: user)))
  }
}

struct User: Codable, Identifiable, Equatable {
  var id: UUID
  var name: String
}
