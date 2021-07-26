import XCTest
import RouterUtils
import NonEmpty
import Prelude
import ApplicativeRouter

enum TestRoute: Equatable {
  case delete(id: Int)
  case fetchAll
  case fetchWithParam(RouteWithParam)
  case fetchWithCodableParam(RouteWithCodableParam)
  case insert(InsertRequest)
  case update(id: Int, update: UpdateRequest)
  
  struct InsertRequest: Codable, Equatable {
    var name: String
  }
  
  struct UpdateRequest: Codable, Equatable {
    var name: String?
  }
}

enum RouteWithParam: Equatable {
  case fetch(foo: String?)
}

enum RouteWithCodableParam: Equatable {
  
  case fetch(CodableParam)
  
  struct CodableParam: Codable, Equatable {
    var userId: Int
    var ref: String
  }
}

class RouterUtilsTestCase: XCTestCase {
  
  var router: Router<TestRoute>!
  
  override func setUp() {
    super.setUp()
    
    let path: NonEmptyArray<String> = .init("/test")
    
    let routers: [Router<TestRoute>] = [
      .delete(/TestRoute.delete(id:), at: path) {
        pathParam(.int)
      },
      .get(/TestRoute.fetchAll, at: path),
      .post(/TestRoute.insert, at: path) {
        jsonBody(TestRoute.InsertRequest.self)
      },
      .post(/TestRoute.update(id:update:), at: path) {
        pathParam(.int) <%> jsonBody(TestRoute.UpdateRequest.self)
      },
      .get(/TestRoute.fetchWithParam, at: .init("test", "param")) {
        .case(/RouteWithParam.fetch(foo:)) {
          queryParam("foo", opt(.string))
        }
      }
//
      
//      .case(/TestRoute.fetchWithCodableParam)
//        <¢> .fetch(/RouteWithCodableParam.fetch, path: .init("test", "codable"))
      
    ]
    
    self.router = routers.reduce(.empty, <|>)
  }
  
}
