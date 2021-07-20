import ApplicativeRouter
import DatabaseClient
import EnvVars
import Router
import SharedModels

public struct ServerEnvironment {
  public var database: DatabaseClient
  public var envVars: EnvVars
  public var router: Router<CRUDRoute<User, InsertUserRequest, UpdateUserRequest>>
  
  public init(
    database: DatabaseClient,
    envVars: EnvVars,
    router: Router<CRUDRoute<User, InsertUserRequest, UpdateUserRequest>>
  ) {
    self.database = database
    self.envVars = envVars
    self.router = router
  }
}
