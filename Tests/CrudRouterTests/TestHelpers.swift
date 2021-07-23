import XCTest
import CrudRouter
import NonEmpty
import Prelude

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

class CrudRouterTestCase: XCTestCase {
  
  var router: Router<TestRoute>!
  
  override func setUp() {
    super.setUp()
    
    let path: NonEmptyArray<String> = .init("test")
    
    let routers: [Router<TestRoute>] = [
      .delete(/TestRoute.delete(id:), path: path, idIso: .int),
      .fetch(/TestRoute.fetchAll, path: path),
      .insert(/TestRoute.insert, path: path),
      .update(/TestRoute.update(id:update:), path: path, idIso: .int),
      
      .case(/TestRoute.fetchWithParam)
        <¢> .fetch(/RouteWithParam.fetch, path: .init("test", "param"), param: (key: "foo", iso: opt(.string))),
      
      .case(/TestRoute.fetchWithCodableParam)
        <¢> .fetch(/RouteWithCodableParam.fetch, path: .init("test", "codable"))
      
    ]
    
    self.router = routers.reduce(.empty, <|>)
  }
  
}
