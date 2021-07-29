import XCTest
import ApplicativeRouter
import CasePaths
import NonEmpty
import Prelude

@testable import RouterUtils

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class RouterUtilsTests: RouterUtilsTestCase {
  
  override func setUp() {
    super.setUp()
    
    // - NOTE: The type names are required when testing on linux, for some reason it gives errors
    //         that it's unable to typecheck in a reasonable time.  On macOS they are not required
    //         which makes the syntax a little nicer.  I have not checked to see if this is resolved
    //         with using the swift 5.4 toolchain.
    self.router = Router<TestRoute>.routes(
      Router<TestRoute>.delete()
        .path("/test") // Make sure leading slashes get removed.
        .path() // Test calling path without strings does nothing.
        .path() // Test even calling path multiple times without strings does nothing.
        .pathParam(.int)
        .case(/TestRoute.delete(id:))
        .end(),
      Router<TestRoute>.get()
        .path("//test") // Make sure leading slashes get removed.
        .case(/TestRoute.fetchAll)
        .end(),
      Router<TestRoute>.get()
        .path("test", "/param") // Make sure leading slashes get removed.
        .queryParam("foo", opt(.string))
        .case(/RouteWithParam.fetch(foo:))
        .case(/TestRoute.fetchWithParam)
        .end(),
      Router<TestRoute>.post()
        .path("test")
        .jsonBody(TestRoute.InsertRequest.self)
        .case(/TestRoute.insert)
        .end(),
      Router<TestRoute>.post()
        .path("test")
      // Both of these syntaxes work.
        .pathParam(.int)
        .jsonBody(TestRoute.UpdateRequest.self)
//        .tuple(pathParam(.int), jsonBody(TestRoute.UpdateRequest.self)) // This also works.
        .case(/TestRoute.update(id:update:))
        .end()
    )
    
    // Both of the below syntax work when embedding deeply nested, I think I prefer the second.
    
//    self.nestedRouter = .get()
//      .path("deep1", "deep2", "deep3")
//      .case(/NestedRoute.Deep1.Deep2.fetch)
//      .case(/NestedRoute.Deep1.deep2)
//      .case(/NestedRoute.deep1)
    
    self.nestedRouter = Router<NestedRoute>.get()
      .path("deep1", "deep2", "deep3")
      .case(/NestedRoute.Deep1.Deep2.fetch)
      .map(PartialIso.case(/NestedRoute.Deep1.deep2)) // This is the `PartialIso.case(_:)` method inside the `map`
      .map(PartialIso.case(/NestedRoute.deep1)) // This is the `PartialIso.case(_:)` method inside the `map`
  }
  
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
  
  func testPutRoute() {
    let router = Router<TestRoute>.put()
      .path("test", "put")
      .tuple(pathParam(.int), jsonBody(TestRoute.UpdateRequest.self))
      .case(/TestRoute.update(id:update:))
      .end()
    let update = TestRoute.UpdateRequest(name: "blob-sr")
    let route = TestRoute.update(id: 43, update: update)
    var request = URLRequest(url: URL(string: "test/put/43")!)
    request.httpMethod = "put"
    request.httpBody = (try! JSONEncoder().encode(update))
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: TestRoute.update(id: 43, update: update)))
  }
  
  func testPatchRoute() {
    let router = Router<TestRoute>.patch()
      .path("test", "patch")
      .tuple(pathParam(.int), jsonBody(TestRoute.UpdateRequest.self))
      .case(/TestRoute.update(id:update:))
      .end()
    let update = TestRoute.UpdateRequest(name: "blob-sr")
    let route = TestRoute.update(id: 43, update: update)
    var request = URLRequest(url: URL(string: "test/patch/43")!)
    request.httpMethod = "patch"
    request.httpBody = (try! JSONEncoder().encode(update))
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertNotNil(request.httpBody)
    XCTAssertEqual(request, router.request(for: TestRoute.update(id: 43, update: update)))
  }
  
  func testOptionsRoute() {
    let router = Router<TestRoute>.options()
      .path("test", "options")
      .case(/TestRoute.options)
      .end()
    let route = TestRoute.options
    var request = URLRequest(url: URL(string: "test/options")!)
    request.httpMethod = "options"
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .options))
  }
  
  func testHeadRoute() {
    let router = Router<TestRoute>.head()
      .path("test", "head")
      .case(/TestRoute.head)
      .end()
    let route = TestRoute.head
    var request = URLRequest(url: URL(string: "test/head")!)
    request.httpMethod = "head"
    
    XCTAssertEqual(route, router.match(request: request))
    XCTAssertEqual(request, router.request(for: .head))
  }

  func testNestedRouter() {
    let route = NestedRoute.deep1(.deep2(.fetch))
    var request = URLRequest(url: URL(string: "deep1/deep2/deep3")!)
    request.httpMethod = "get"
    
    XCTAssertEqual(route, nestedRouter.match(request: request))
    XCTAssertEqual(request, nestedRouter.request(for: .deep1(.deep2(.fetch))))
  }
}
