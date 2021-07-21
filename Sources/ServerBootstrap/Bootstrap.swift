import DatabaseClientLive
import Either
import EnvVars
import Foundation
import NIO
import PostgresKit
import Prelude
import ServerRouter
import SiteMiddleware

public func bootstrap(
  eventLoopGroup: EventLoopGroup
) -> EitherIO<Error, ServerEnvironment> {
  EitherIO.debug(prefix: "Bootstraping playground...")
    .flatMap(loadEnvVars)
    .flatMap(loadEnvironment(eventLoopGroup: eventLoopGroup))
    .flatMap(fireAndForget(connectToPostgres(eventLoopGroup: eventLoopGroup)))
    .flatMap(fireAndForget(.debug(prefix: "Swift-Web Playground Bootstraped!")))
}

private let stepDivider = EitherIO.debug(prefix: "  -----------------------------")

private func connectToPostgres(
  eventLoopGroup: EventLoopGroup
) -> (ServerEnvironment) -> EitherIO<Error, Void> {
  { environment in
    EitherIO.debug(prefix: "Connecting to PostgreSQL")
      .flatMap {
        return environment.database.migrate()
      }
      .catch { EitherIO.debug(prefix: "  Error! \($0)").flatMap(const(throwE($0))) }
      .retry(maxRetries: 999_999, backoff: const(.seconds(1)))
      .flatMap(const(.debug(prefix: "Connected to PostgreSQL!")))
      .flatMap(const(stepDivider))
  }
}

private func loadEnvVars() -> EitherIO<Error, EnvVars> {
  let envFilePath = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent(".playground-env")
  
  let decoder = JSONDecoder()
  let encoder = JSONEncoder()
  
  let defaultEnvVars = EnvVars()
  let defaultEnvVarsDict = (try? encoder.encode(defaultEnvVars))
    .flatMap { try? decoder.decode([String: String].self, from: $0) }
    ?? [:]
  
  let fileEnvDict = (try? Data(contentsOf: envFilePath))
    .flatMap { try? decoder.decode([String: String].self, from: $0) }
    ?? [:]
  
  let envVarDict = defaultEnvVarsDict
    .merging(fileEnvDict, uniquingKeysWith: { $1 })
    .merging(ProcessInfo.processInfo.environment, uniquingKeysWith: { $1 })
  
  let envVars = (try? JSONSerialization.data(withJSONObject: envVarDict))
    .flatMap { try? decoder.decode(EnvVars.self, from: $0) }
    ?? defaultEnvVars
  
  return pure(envVars)
}

private func loadEnvironment(
  eventLoopGroup: EventLoopGroup
) -> (EnvVars) -> EitherIO<Error, ServerEnvironment> {
  { envVars in
    return pure(
      ServerEnvironment(
        database: .live(
          pool: .init(
            source: PostgresConnectionSource(
              configuration: PostgresConfiguration(url: envVars.databaseUrl)!
            ),
            on: eventLoopGroup)
        ),
        envVars: envVars,
        router: router(decoder: JSONDecoder(), encoder: JSONEncoder())
      )
    )
  }
}

extension EitherIO where A == Void, E == Error {
  static func debug(prefix: String) -> EitherIO {
    EitherIO(
      run: IO {
        print(prefix)
        return .right(())
    })
  }
}

private func fireAndForget<A, E: Error>(
  _ b: EitherIO<E, Void>
) -> (A) -> EitherIO<E, A> {
  return { a in
    b.flatMap { _ in
      pure(a)
    }
  }
}

private func fireAndForget<A, E: Error>(
  _ f: @escaping (A) -> EitherIO<E, Void>
) -> (A) -> EitherIO<E, A> {
  return { a in
    f(a).flatMap { _ in
      pure(a)
    }
  }
}
