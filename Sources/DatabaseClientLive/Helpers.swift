import Either
import Foundation
import PostgresKit

extension EitherIO where E == Error {
  /// Create a new `EitherIO` from an event loop future.
  init(_ eventLoopFuture: @escaping @autoclosure () -> EventLoopFuture<A>) {
    self.init(
      run: .init { callback in
        eventLoopFuture()
          .whenComplete {
            result in callback(.init(result: result))
          }
      }
    )
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
  func run(_ query: SQLQueryString) -> EitherIO<Error, Void> {
    EitherIO(self.sql().raw(query).run())
  }
}

private let logger = Logger(label: "Sqlite")

extension EventLoopGroupConnectionPool where Source == PostgresConnectionSource {
  var sqlDatabase: SQLDatabase {
    self.database(logger: logger).sql()
  }
}

extension SQLQueryFetcher {
  
  func first<D>(decoding: D.Type) -> EitherIO<Error, D?> where D: Decodable {
    .init(self.first(decoding: D.self))
  }

  func all<D>(decoding: D.Type) -> EitherIO<Error, [D]> where D: Decodable {
    .init(self.all(decoding: D.self))
  }

  func run() -> EitherIO<Error, Void> {
    .init(self.run())
  }
}

extension SQLQueryBuilder {
  func run() -> EitherIO<Error, Void> {
    .init(self.run())
  }
}
