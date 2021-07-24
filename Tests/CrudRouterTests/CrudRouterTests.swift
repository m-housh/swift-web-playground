import XCTest
@testable import CrudRouter

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class CrudRouterTests: CrudRouterTestCase {
  
  func testDeleteRoute() {
    let route = TestRoute.delete(id: 1)
    var request = URLRequest(url: URL(string: "test/1")!)
    request.httpMethod = "delete"
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: TestRoute.delete(id: 1)))
  }
  
  func testFetchAllRoute() {
    let route = TestRoute.fetchAll
    var request = URLRequest(url: URL(string: "test")!)
    request.httpMethod = "get"
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: TestRoute.fetchAll))
  }
  
  func testFetchWithParamRoute() {
    let route = TestRoute.fetchWithParam(.fetch(foo: "bar"))
    var request = URLRequest(url: URL(string: "test/param?foo=bar")!)
    request.httpMethod = "get"
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: TestRoute.fetchWithParam(.fetch(foo: "bar"))))
  }
  
  // Currently doesn't work, the codable tests are also commented out in the swift-web
  // framework, so assuming there is a bug somewhere that needs resolved.
  
//  func testFetchWithCodableParamRoute() {
//    let route = TestRoute.fetchWithCodableParam(.fetch(.init(userId: 43, ref: "blob")))
//    var request = URLRequest(url: URL(string: "test/codable?ref=blob&userId='43'")!)
//    request.httpMethod = "get"
//    XCTAssertEqual(route, router.match(request: request))
//    XCTAssertEqual(request, router.request(for: TestRoute.fetchWithCodableParam(.fetch(.init(userId: 43, ref: "blob")))))
//  }
  
  func testInsertRoute() {
    let insert = TestRoute.InsertRequest(name: "blob")
    let route = TestRoute.insert(insert)
    var request = URLRequest(url: URL(string: "test")!)
    request.httpMethod = "post"
    request.httpBody = (try! JSONEncoder().encode(insert))
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: TestRoute.insert(insert)))
  }

  
  func testUpdateRoute() {
    let update = TestRoute.UpdateRequest(name: "blob-sr")
    let route = TestRoute.update(id: 43, update: update)
    var request = URLRequest(url: URL(string: "test/43")!)
    request.httpMethod = "post"
    request.httpBody = (try! JSONEncoder().encode(update))
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: TestRoute.update(id: 43, update: update)))
  }

}
