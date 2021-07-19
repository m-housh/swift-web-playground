import ApplicativeRouter
import DatabaseClient
import Router
import SharedModels

public struct ServerEnvironment {
  public var database: DatabaseClient
  public var router: UserRouter
}
