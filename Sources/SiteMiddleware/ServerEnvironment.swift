import ApplicativeRouter
import DatabaseClient
import Router
import SharedModels

public struct ServerEnvironment {
  public var database: DatabaseClient
  public var router: Router<CRUDRoute<User, InsertUser, User>>
  
  public init(database: DatabaseClient, router: Router<CRUDRoute<User, InsertUser, User>>) {
    self.database = database
    self.router = router
  }
}
