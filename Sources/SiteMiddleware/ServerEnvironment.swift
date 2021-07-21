import ApplicativeRouter
import CrudRouter
import DatabaseClient
import EnvVars
import ServerRouter
import SharedModels

public struct ServerEnvironment {
  public var database: DatabaseClient
  public var envVars: EnvVars
  public var router: Router<ServerRoute>
  
  public init(
    database: DatabaseClient,
    envVars: EnvVars,
    router: Router<ServerRoute>
  ) {
    self.database = database
    self.envVars = envVars
    self.router = router
  }
}
