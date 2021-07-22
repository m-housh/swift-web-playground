import DatabaseClient
import DatabaseCrudHelpers
import Either
import Foundation
import PostgresKit
import Prelude
import SharedModels

extension DatabaseClient {

  public static func live(
    pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
  ) -> Self {
    Self.init(
      deleteFavorite: delete(from: Table.favorites, on: pool),
      deleteUser: delete(from: Table.users, on: pool),
      fetchFavorites: { optionalUserId in
        let builder = fetchBuilder(from: Table.favorites, on: pool)
        if let userId = optionalUserId {
          builder.where("userId", .equal, userId)
        }
        return builder.all(decoding: UserFavorite.self)
      },
      fetchUsers: fetch(from: Table.users, on: pool),
      fetchFavorite: fetchId(from: Table.favorites, on: pool),
      insertFavorite: insert(to: Table.favorites, on: pool),
      fetchUser: fetchId(from: Table.users, on: pool),
      insertUser: insert(to: Table.users, on: pool),
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
      shutdown: .catching { try pool.syncShutdownGracefully() },
      updateFavorite: update(table: Table.favorites, on: pool),
      updateUser: update(table: Table.users, on: pool)
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

enum Table: CustomStringConvertible {
  case users
  case favorites

  var tableName: String {
    switch self {
    case .users:
      return "users"
    case .favorites:
      return "user_favorites"
    }
  }

  var description: String { tableName }
}

extension Table: SQLExpression {
  func serialize(to serializer: inout SQLSerializer) {
    SQLIdentifier(tableName).serialize(to: &serializer)
  }
}
