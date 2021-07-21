import Foundation

public struct EnvVars: Codable {

  public var appEnv: AppEnv
  public var baseUrl: URL
  public var databaseUrl: String
  public var port: String

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

  public enum AppEnv: String, Codable {
    case development
    case testing
  }
}
