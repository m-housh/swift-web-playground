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
      deleteFavorite: delete(from: "user_favorites", on: pool),
      deleteUser: delete(from: "users", on: pool),
      fetchFavorites: { optionalUserId in
        var request = pool.sqlDatabase.select()
          .columns(.all)
          .from("user_favorites")
        
        if let userId = optionalUserId {
          request = request.where("userId", .equal, userId)
        }
        
        return request.all(decoding: UserFavorite.self)
        
      },
      fetchUsers: fetch(from: "users", on: pool),
      fetchFavorite: fetchId(from: "user_favorites", on: pool),
      insertFavorite: { request -> EitherIO<Error, UserFavorite> in
        pool.sqlDatabase.insert(into: "user_favoirtes")
          .columns("userId", "description")
          .values(request.userId, request.description)
          .returning(.all)
          .first(decoding: UserFavorite.self)
          .mapExcept(requireSome("insertFavorite(\(request))"))
      },
      fetchUser: fetchId(from: "users", on: pool),
      insertUser: { request -> EitherIO<Error, User> in
        pool.sqlDatabase.insert(into: "users")
          .columns("name")
          .values(request.name)
          .returning("*")
          .first(decoding: User.self)
          .mapExcept(requireSome("insertUser(\(request))"))
      },
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
              CREATE TABLE IF NOT EXISTS "users"(
                "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
                "userId" uuid REFERENCES "users" ("id") NOT NULL,
                "description" character varying NOT NULL
              )
              """
          )
        ])
        .map(const(()))

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
      updateFavorite: { request -> EitherIO<Error, UserFavorite> in
        pool.sqlDatabase.update("user_favorites")
          .where("id", .equal, request.id)
          .set("description", to: request.description)
          .returning(.all)
          .first(decoding: UserFavorite.self)
          .mapExcept(requireSome("updateFavorite(\(request))"))
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

func delete<ID>(
  from tableName: String,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> (ID) -> EitherIO<Error, Void>
  where ID: Encodable
{
  { id -> EitherIO<Error, Void> in
    pool.sqlDatabase.delete(from: tableName)
      .where("id", .equal, id)
      .run()
  }
}

func fetch<A>(
  from tableName: String,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> () -> EitherIO<Error, [A]>
  where A: Decodable
{
  {
    pool.sqlDatabase.select()
      .columns(.all)
      .from(tableName)
      .all(decoding: A.self)
  }
}

func fetchId<ID, A>(
  from tableName: String,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> (ID) -> EitherIO<Error, A>
  where ID: Encodable, A: Decodable
{
  { id -> EitherIO<Error, A> in
    pool.sqlDatabase.select()
      .columns(.all)
      .from(tableName)
      .first(decoding: A.self)
      .mapExcept(requireSome("insert: \(tableName) : \(id)"))
  }
}

//func insert<I, A>(
//  to tableName: String,
//  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
//) -> (I) -> EitherIO<Error, A>
//  where I: Identifiable, I.ID: Encodable, A: Decodable
//{
//  { request in
//    pool.sqlDatabase.insert(into: tableName)
//      .
//  }
//}
