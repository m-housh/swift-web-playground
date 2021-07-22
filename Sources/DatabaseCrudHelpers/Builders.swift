import Foundation
import PostgresKit

public func deleteBuilder<ID>(
  id: ID,
  from table: SQLExpression,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>,
  idColumn: SQLExpression = SQLIdentifier("id")
) -> SQLDeleteBuilder
where ID: Encodable
{
  pool.sqlDatabase.delete(from: table)
    .where(idColumn, .equal, SQLBind(id))
}

public func fetchBuilder(
  from table: SQLExpression,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> SQLSelectBuilder
{
  pool.sqlDatabase.select()
    .columns(.all)
    .from(table)
}

public func fetchIdBuilder<ID>(
  id: ID,
  from table: SQLExpression,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>,
  idColumn: SQLExpression = SQLIdentifier("id")
) -> SQLSelectBuilder
where ID: Encodable
{
  pool.sqlDatabase.select()
    .columns(.all)
    .from(table)
    .where(idColumn, .equal, SQLBind(id))
}

public func insertBuilder<Insert>(
  inserting model: Insert,
  to table: SQLExpression,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) throws -> SQLInsertBuilder
where Insert: Encodable
{
  try pool.sqlDatabase.insert(into: table)
    .model(model)
}

public func updateBuilder<Update>(
  updating model: Update,
  table: SQLExpression,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>,
  idColumn: SQLExpression = SQLIdentifier("id")
) throws -> SQLUpdateBuilder
where Update: Encodable, Update: Identifiable, Update.ID: Encodable
{
  try pool.sqlDatabase.update(table)
    .where(idColumn, .equal, SQLBind(model.id))
    .set(model: model)
}
