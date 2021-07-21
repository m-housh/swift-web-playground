import Either
import Foundation
import PostgresKit

public func delete<ID>(
  from table: SQLExpression,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>,
  idColumn: SQLExpression = SQLIdentifier("id")
) -> (ID) -> EitherIO<Error, Void>
  where ID: Encodable
{
  { id -> EitherIO<Error, Void> in
    deleteBuilder(id: id, from: table, on: pool).run()
  }
}

public func fetch<A>(
  from table: SQLExpression,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> () -> EitherIO<Error, [A]>
  where A: Decodable
{
  {
    fetchBuilder(from: table, on: pool)
      .all(decoding: A.self)
  }
}

public func fetchId<ID, A>(
  from table: SQLExpression,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>,
  idColumn: SQLExpression = SQLIdentifier("id")
) -> (ID) -> EitherIO<Error, A>
  where ID: Encodable, A: Decodable
{
  { id -> EitherIO<Error, A> in
    fetchIdBuilder(id: id, from: table, on: pool)
      .first(decoding: A.self)
      .mapExcept(requireSome("fetchId: \(table) : \(id)"))
  }
}

public func insert<I, A>(
  to table: SQLExpression,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> (I) -> EitherIO<Error, A>
  where I: Encodable, A: Decodable
{
  { request in
      .catching {
        try insertBuilder(inserting: request, to: table, on: pool)
          .returning(.all)
          .first(decoding: A.self)
          .mapExcept(requireSome("insert: \(table) : \(request)"))
      }
  }
}

public func update<U, A>(
  table: SQLExpression,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> (U) -> EitherIO<Error, A>
  where U: Encodable, U: Identifiable, U.ID: Encodable, A: Decodable
{
  { request in
      .catching {
        try updateBuilder(updating: request, table: table, on: pool)
          .returning(.all)
          .first(decoding: A.self)
          .mapExcept(requireSome("update: \(table) : \(request)"))
      }
  }
}

func requireSome<A>(
  _ message: String
) -> (Either<Error, A?>) -> Either<Error, A> {
  { e in
    switch e {
    case let .left(e):
      return .left(e)
    case let .right(a):
      return a.map(Either.right) ?? .left(RequireSomeError(message: message))
    }
  }
}

struct RequireSomeError: Error {
  let message: String
}
