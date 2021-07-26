import Foundation
import NonEmpty
import PostgresKit

/// A namespace for creating common sql builders, that can be extended to fit the needs of the caller.
public enum DatabaseBuilders {

  /// Creates an `SQLDeleteBuilder` that can be extended or executed later.
  ///
  /// - Parameters:
  ///    - id: The id of the model to delete from the database.
  ///    - table: The table identifier to delete the model from.
  ///    - pool: The connection pool to run the request on.
  ///    - idColumn: The id column identifier, defaults to "id".
  public static func delete<ID>(
    id: ID,
    from table: SQLExpression,
    on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>,
    idColumn: SQLExpression = SQLIdentifier("id")
  ) -> SQLDeleteBuilder
  where ID: Encodable {
    pool.sqlDatabase.delete(from: table)
      .where(idColumn, .equal, SQLBind(id))
  }

  /// Creates an `SQLSelectBuilder` that can be extended or executed later.
  ///
  /// Typically used to fetch all / a list of models from the database.
  ///
  /// - Parameters:
  ///    - table: The table identifier to fetch the model from.
  ///    - pool: The connection pool to run the request on.
  ///    - columns: The columns to return from the table, defaults all columns.
  public static func fetch(
    from table: SQLExpression,
    on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>,
    returning columns: NonEmptyArray<String> = .init(.all)
  ) -> SQLSelectBuilder {
    pool.sqlDatabase.select()
      .columns(columns.rawValue)
      .from(table)
  }

  /// Creates an `SQLSelectBuilder` that can be extended or executed later.
  ///
  /// Used to fetch a specific model by id.
  ///
  /// - Parameters:
  ///    - id: The id of the model to delete from the database.
  ///    - table: The table identifier to fetch the model from.
  ///    - pool: The connection pool to run the request on.
  ///    - idColumn: The id column identifier, defaults to "id".
  ///    - columns: The columns to return from the table, defaults all columns.
  public static func fetchId<ID>(
    id: ID,
    from table: SQLExpression,
    on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>,
    idColumn: SQLExpression = SQLIdentifier("id"),
    returning columns: NonEmptyArray<String> = .init(.all)
  ) -> SQLSelectBuilder
  where ID: Encodable {
    fetch(from: table, on: pool, returning: columns)
      .where(idColumn, .equal, SQLBind(id))
  }

  /// Creates an `SQLInsertBuilder` that can be extended or executed later.
  ///
  /// Used to insert a new model.
  ///
  /// - Parameters:
  ///    - model: The model to insert in the database.
  ///    - table: The table identifier to insert the model.
  ///    - pool: The connection pool to run the request on.
  ///    - idColumn: The id column identifier, defaults to "id".
  public static func insert<Insert>(
    inserting model: Insert,
    to table: SQLExpression,
    on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
  ) throws -> SQLInsertBuilder
  where Insert: Encodable {
    try pool.sqlDatabase.insert(into: table)
      .model(model)
  }

  /// Creates an `SQLSelectBuilder` that can be extended or executed later.
  ///
  /// Used to fetch a specific model by id.
  ///
  /// - Parameters:
  ///    - id: The id of the model to update in the database.
  ///    - table: The table identifier to update the model on.
  ///    - pool: The connection pool to run the request on.
  ///    - idColumn: The id column identifier, defaults to "id".
  public static func update<Update>(
    updating model: Update,
    table: SQLExpression,
    on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>,
    idColumn: SQLExpression = SQLIdentifier("id")
  ) throws -> SQLUpdateBuilder
  where Update: Encodable, Update: Identifiable, Update.ID: Encodable {
    try pool.sqlDatabase.update(table)
      .where(idColumn, .equal, SQLBind(model.id))
      .set(model: model)
  }
}
