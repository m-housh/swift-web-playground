import Either
import Foundation
import PostgresKit

public enum DatabaseCrud {

  /// Creates a function that can be used to delete a model by id from the database.
  ///
  /// - Parameters:
  ///    - table: The table identifier to delete the model from.
  ///    - pool: The connection pool to run the request on.
  ///    - idColumn: The id column identifier, defaults to "id".
  public static func delete<ID>(
    from table: SQLExpression,
    on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>,
    idColumn: SQLExpression = SQLIdentifier("id")
  ) -> (ID) -> EitherIO<Error, Void>
  where ID: Encodable {
    { id -> EitherIO<Error, Void> in
      DatabaseBuilders.delete(id: id, from: table, on: pool).run()
    }
  }

  /// Creates a function that can be used to fetch all models from the database.
  ///
  /// - Parameters:
  ///    - table: The table identifier to delete the model from.
  ///    - pool: The connection pool to run the request on.
  public static func fetch<Model>(
    from table: SQLExpression,
    on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
  ) -> () -> EitherIO<Error, [Model]>
  where Model: Decodable {
    {
      DatabaseBuilders.fetch(from: table, on: pool)
        .all(decoding: Model.self)
    }
  }

  /// Creates a function that can be used to fetch a model by id from the database.
  ///
  /// - Parameters:
  ///    - table: The table identifier to delete the model from.
  ///    - pool: The connection pool to run the request on.
  ///    - idColumn: The id column identifier, defaults to "id".
  public static func fetchId<ID, Model>(
    from table: SQLExpression,
    on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>,
    idColumn: SQLExpression = SQLIdentifier("id")
  ) -> (ID) -> EitherIO<Error, Model>
  where ID: Encodable, Model: Decodable {
    { id -> EitherIO<Error, Model> in
      DatabaseBuilders.fetchId(id: id, from: table, on: pool)
        .first(decoding: Model.self)
        .mapExcept(requireSome("fetchId: \(table) : \(id)"))
    }
  }

  /// Creates a function that can be used to insert a model into the database.
  ///
  /// - Parameters:
  ///    - table: The table identifier to delete the model from.
  ///    - pool: The connection pool to run the request on.
  public static func insert<Insert, Model>(
    to table: SQLExpression,
    on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
  ) -> (Insert) -> EitherIO<Error, Model>
  where Insert: Encodable, Model: Decodable {
    { request in
      .catching {
        try DatabaseBuilders.insert(inserting: request, to: table, on: pool)
          .returning(.all)
          .first(decoding: Model.self)
          .mapExcept(requireSome("insert: \(table) : \(request)"))
      }
    }
  }

  /// Creates a function that can be used to update a model by id in the database.
  ///
  /// - Parameters:
  ///    - table: The table identifier to delete the model from.
  ///    - pool: The connection pool to run the request on.
  ///    - idColumn: The id column identifier, defaults to "id".
  public static func update<Update, Model>(
    table: SQLExpression,
    on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>,
    idColumn: SQLExpression = SQLIdentifier("id")
  ) -> (Update) -> EitherIO<Error, Model>
  where Update: Encodable, Update: Identifiable, Update.ID: Encodable, Model: Decodable {
    { request in
      .catching {
        try DatabaseBuilders.update(updating: request, table: table, on: pool, idColumn: idColumn)
          .returning(.all)
          .first(decoding: Model.self)
          .mapExcept(requireSome("update: \(table) : \(request)"))
      }
    }
  }
}

private func requireSome<A>(
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
