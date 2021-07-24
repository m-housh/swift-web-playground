import DatabaseClient
import DatabaseCrudHelpers
import Either
import Foundation
import PostgresKit
import Prelude
import SharedModels

extension DatabaseClient {

  /// Creates the live implementation of a `DatabaseClient`.
  ///
  /// - Parameters:
  ///   - pool: The event loop connection pool, used to connect to the database.
  public static func live(
    pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
  ) -> Self {
    Self.init(
      users: UserClient(pool: pool),
      favorites: UserFavoriteClient(pool: pool),
      migrate: { () -> EitherIO<Error, Void> in
        let database = pool.database(logger: Logger(label: "Postgres"))

        return sequence([
          database.run(
            #"CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "public""#
          ),
          database.run(
            """
            CREATE TABLE IF NOT EXISTS "users"(
              "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
              "name" character varying NOT NULL
            )
            """
          ),
          database.run(
            """
            CREATE TABLE IF NOT EXISTS "user_favorites"(
              "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
              "userId" uuid REFERENCES "users" ("id") NOT NULL,
              "description" character varying NOT NULL
            )
            """
          ),
        ])
        .map(const(()))

      },
      shutdown: { .catching { try pool.syncShutdownGracefully() } }
    )
  }

  #if DEBUG
    public func resetForTesting(pool: EventLoopGroupConnectionPool<PostgresConnectionSource>) throws
    {
      let database = pool.database(logger: Logger(label: "Postgres"))
      try database.run("DROP SCHEMA IF EXISTS public CASCADE").run.perform().unwrap()
      try database.run("CREATE SCHEMA public").run.perform().unwrap()
      try database.run("GRANT ALL ON SCHEMA public TO playground").run.perform().unwrap()
      try database.run("GRANT ALL ON SCHEMA public TO public").run.perform().unwrap()
      try self.migrate().run.perform().unwrap()
    }
  #endif
}

/// Represents the table names in the database.
enum Table: CustomStringConvertible, SQLExpression {

  case users
  case favorites

  /// The database table name.
  var tableName: String {
    switch self {
    case .users:
      return "users"
    case .favorites:
      return "user_favorites"
    }
  }

  var description: String { tableName }

  func serialize(to serializer: inout SQLSerializer) {
    SQLIdentifier(tableName).serialize(to: &serializer)
  }
}

extension DatabaseClient.UserClient {

  init(pool: EventLoopGroupConnectionPool<PostgresConnectionSource>) {
    self.init(
      delete: DatabaseCrud.delete(from: Table.users, on: pool),
      fetch: DatabaseCrud.fetch(from: Table.users, on: pool),
      fetchId: DatabaseCrud.fetchId(from: Table.users, on: pool),
      insert: DatabaseCrud.insert(to: Table.users, on: pool),
      update: DatabaseCrud.update(table: Table.users, on: pool)
    )
  }
}

extension DatabaseClient.UserFavoriteClient {

  init(pool: EventLoopGroupConnectionPool<PostgresConnectionSource>) {
    self.init(
      delete: DatabaseCrud.delete(from: Table.favorites, on: pool),
      fetch: { optionalUserId in
        let builder = DatabaseBuilders.fetch(from: Table.favorites, on: pool)
        if let userId = optionalUserId {
          builder.where("userId", .equal, userId)
        }
        return builder.all(decoding: UserFavorite.self)
      },
      fetchId: DatabaseCrud.fetchId(from: Table.favorites, on: pool),
      insert: DatabaseCrud.insert(to: Table.favorites, on: pool),
      update: DatabaseCrud.update(table: Table.favorites, on: pool)
    )
  }
}
