import ApplicativeRouter
import DatabaseClient
import EnvVars
import ServerRouter
import SharedModels

/// Holds the server environment values that can be used by middleware's.  Gives access to the
/// database client, the environment variables, and the router.
public struct ServerEnvironment {

  /// The database client to use for interacting with the database.
  public var database: DatabaseClient

  /// The environment variables loaded from the shell / file / defaults.
  public var envVars: EnvVars

  /// The router that knows how to parse incoming requests to types that we can work with to create responses.
  public var router: Router<ApiRoute>

  /// Create a new `ServerEnvironment`.
  ///
  /// - Parameters:
  ///   - database: The database client to use for interacting with the database.
  ///   - envVars: The environment variables loaded from the shell / file / defaults.
  ///   - router: The router that knows how to parse incoming requests to types that we can work with to create responses.
  public init(
    database: DatabaseClient,
    envVars: EnvVars,
    router: Router<ApiRoute>
  ) {
    self.database = database
    self.envVars = envVars
    self.router = router
  }
}
