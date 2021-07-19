import DatabaseClientLive
import Either
import Foundation
import NIO
import PostgresKit
import Prelude
import Router
import SiteMiddleware

public func bootstrap(
  eventLoopGroup: EventLoopGroup
) -> EitherIO<Error, ServerEnvironment> {
  EitherIO.debug(prefix: "Bootstraping playground...")
    .flatMap({ loadEnvironment(eventLoopGroup: eventLoopGroup) })
    .flatMap(fireAndForget(connectToPostgres(eventLoopGroup: eventLoopGroup)))
    .flatMap(fireAndForget(.debug(prefix: "playground Bootstraped!")))
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

private func loadEnvironment(
  eventLoopGroup: EventLoopGroup
) -> EitherIO<Error, ServerEnvironment> {
    return pure(
      ServerEnvironment(
        database: .live(
          pool: .init(
            source: PostgresConnectionSource(
              configuration: PostgresConfiguration(
                url: "postgres://playground:playground@localhost:5432/playground_development"
              )!
            ),
            on: eventLoopGroup)
        ),
        router: UserRouter.init("users")
      )
    )
//  }
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
