import XCTest
import CasePaths
import RouterUtils
import NonEmpty
import Prelude
import ApplicativeRouter

enum TestRoute: Equatable {
  case delete(id: Int)
  case fetchAll
  case fetchWithParam(RouteWithParam)
  case head
  case insert(InsertRequest)
  case options
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

enum NestedRoute: Equatable {
  case deep1(Deep1)
  
  enum Deep1: Equatable {
    
    case deep2 (Deep2)
    
    enum Deep2: Equatable {
      case fetch
    }
  }
}

class RouterUtilsTestCase: XCTestCase {
  
  var router: Router<TestRoute>!
  var nestedRouter: Router<NestedRoute>!
  
  override func setUp() {
    super.setUp()
  }
}
