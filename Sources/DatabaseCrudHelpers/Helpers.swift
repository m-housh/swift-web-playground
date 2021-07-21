import Either
import Foundation
import PostgresKit

extension EitherIO where E == Error {
  /// Create a new `EitherIO` from an event loop future.
  public init(_ eventLoopFuture: @escaping @autoclosure () -> EventLoopFuture<A>) {
    self.init(
      run: .init { callback in
        eventLoopFuture()
          .whenComplete {
            result in callback(.init(result: result))
          }
      }
    )
  }

  /// Return an `EitherIO` from a closure that can throw errors.
  public static func catching(_ work: @escaping () throws -> EitherIO) -> EitherIO {
    do {
      return try work()
    } catch {
      return .init(run: .init { .left(error) })
    }
  }
}

extension Either where L: Error {
  init(result: Result<R, L>) {
    switch result {
    case let .success(value):
      self = .right(value)
    case let .failure(error):
      self = .left(error)
    }
  }
}

extension PostgresDatabase {
  public func run(_ query: SQLQueryString) -> EitherIO<Error, Void> {
    EitherIO(self.sql().raw(query).run())
  }
}

private let logger = Logger(label: "Sqlite")

extension EventLoopGroupConnectionPool where Source == PostgresConnectionSource {
  public var sqlDatabase: SQLDatabase {
    self.database(logger: logger).sql()
  }
}

extension SQLQueryFetcher {

  public func first<D>(decoding: D.Type) -> EitherIO<Error, D?> where D: Decodable {
    .init(self.first(decoding: D.self))
  }

  public func all<D>(decoding: D.Type) -> EitherIO<Error, [D]> where D: Decodable {
    .init(self.all(decoding: D.self))
  }

  public func run() -> EitherIO<Error, Void> {
    .init(self.run())
  }
}

extension SQLQueryBuilder {
  public func run() -> EitherIO<Error, Void> {
    .init(self.run())
  }
}

extension String {
  public static let all = "*"
}

//extension String: SQLExpression {
//  public func serialize(to serializer: inout SQLSerializer) {
//    SQLIdentifier(self).serialize(to: &serializer)
//  }
//}
