import Foundation

/// Represents environment variables for the server environment.  These are loaded from the shell environment and / or an
/// `.playground-env` file located in the root directory of the application.  And also includes defaults if no values are found in either of
/// those locations.
///
/// Adding new values to this struct, also requires them to be added to the `Bootstrap/playground-env-example` file.
///
public struct EnvVars: Codable {

  /// The application environment, i.e. (development / testing, etc.)
  public var appEnv: AppEnv
  
  /// The base url, used by the router to create / parse urls.
  public var baseUrl: URL
  
  /// The database url used to connect to the database.
  public var databaseUrl: String
  
  /// The port the application is running on.
  public var port: String

  /// Create a new `EnvVars`.
  ///
  /// - Parameters:
  ///    - appEnv: The application environment, i.e. (development / testing, etc.)
  ///    - baseUrl: The base url, used by the router to create / parse urls.
  ///    - databaseUrl: The database url used to connect to the database.
  ///    - port: The port the application is running on.
  public init(
    appEnv: AppEnv = .development,
    baseUrl: URL = URL(string: "http://localhost:8080")!,
    databaseUrl: String = "postgres://playground:playground@localhost:5432/playground_development",
    port: String = "8080"
  ) {
    self.appEnv = appEnv
    self.baseUrl = baseUrl
    self.databaseUrl = databaseUrl
    self.port = port
  }

  private enum CodingKeys: String, CodingKey {
    case appEnv = "APP_ENV"
    case baseUrl = "BASE_URL"
    case databaseUrl = "DATABASE_URL"
    case port = "PORT"
  }

  /// Represents the application environment.
  public enum AppEnv: String, Codable {
    case development
    case testing
  }
}
