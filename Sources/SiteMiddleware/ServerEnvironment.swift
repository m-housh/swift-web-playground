import ApplicativeRouter
import CrudRouter
import DatabaseClient
import EnvVars
import ServerRouter
import SharedModels

public struct ServerEnvironment {
  public var database: DatabaseClient
  public var envVars: EnvVars
  public var router: Router<CRUDRoute<User, DatabaseClient.InsertUserRequest, DatabaseClient.UpdateUserRequest>>
  
  public init(
    database: DatabaseClient,
    envVars: EnvVars,
    router: Router<CRUDRoute<User, DatabaseClient.InsertUserRequest, DatabaseClient.UpdateUserRequest>>
  ) {
    self.database = database
    self.envVars = envVars
    self.router = router
  }
}
