import DatabaseClient
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
      deleteUser: { id -> EitherIO<Error, Void> in
        pool.sqlDatabase.delete(from: "users")
          .where("id", .equal, id)
          .run()
      },
      fetchUsers: { () -> EitherIO<Error, [User]> in
        pool.sqlDatabase.select()
          .column("*")
          .from("users")
          .all(decoding: User.self)
      },
      fetchUser: { id -> EitherIO<Error, User> in
        pool.sqlDatabase.select()
          .column("*")
          .from("users")
          .where("id", .equal, id)
          .first(decoding: User.self)
          .mapExcept(requireSome("fetchUser(\(id))"))
      },
      insertUser: { request -> EitherIO<Error, User> in
        pool.sqlDatabase.insert(into: "users")
          .columns("name")
          .values(request.name)
          .returning("*")
          .first(decoding: User.self)
          .mapExcept(requireSome("insertUser(\(request))"))
      },
      migrate: { () -> EitherIO<Error, Void> in
        pool.database(logger: Logger(label: "Postgres"))
          .run(
            """
              CREATE TABLE IF NOT EXISTS "users"(
                "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY NOT NULL,
                "name" character varying NOT NULL
              )
              """
          )

      },
      shutdown: {
        .init(
          run: .init {
          do {
            try pool.syncShutdownGracefully()
            return .right(())
          } catch {
            return .left(error)
          }
        })
      },
      updateUser: { request -> EitherIO<Error, User> in
        pool.sqlDatabase.update("users")
          .where("id", .equal, request.id)
          .set("name", to: request.name)
          .returning("*")
          .first(decoding: User.self)
          .mapExcept(requireSome("updateUser(\(request))"))

      }
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
