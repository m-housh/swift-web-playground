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
      deleteFavorite: delete(from: .favorites, on: pool),
      deleteUser: delete(from: .users, on: pool),
      fetchFavorites: _fetchFavorites(on: pool),
      fetchUsers: fetch(from: .users, on: pool),
      fetchFavorite: fetchId(from: .favorites, on: pool),
      insertFavorite: insert(to: .favorites, on: pool),
      fetchUser: fetchId(from: .users, on: pool),
      insertUser: insert(to: .users, on: pool),
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
      updateFavorite: update(table: .favorites, on: pool),
      updateUser: update(table: .users, on: pool)
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
  from table: Table,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> (ID) -> EitherIO<Error, Void>
  where ID: Encodable
{
  { id -> EitherIO<Error, Void> in
    pool.sqlDatabase.delete(from: table)
      .where("id", .equal, id)
      .run()
  }
}

func fetch<A>(
  from table: Table,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> () -> EitherIO<Error, [A]>
  where A: Decodable
{
  {
    pool.sqlDatabase.select()
      .columns(.all)
      .from(table)
      .all(decoding: A.self)
  }
}

func _fetchFavorites(
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> (User.ID?) -> EitherIO<Error, [UserFavorite]>
{
  { userId in
    let table: Table = .favorites
    guard let userId = userId else {
      return fetch(from: table, on: pool)()
    }
    
    return pool.sqlDatabase.select()
      .columns(.all)
      .from(table)
      .where("userId", .equal, userId)
      .all(decoding: UserFavorite.self)
  }
}

func fetchId<ID, A>(
  from table: Table,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> (ID) -> EitherIO<Error, A>
  where ID: Encodable, A: Decodable
{
  { id -> EitherIO<Error, A> in
    pool.sqlDatabase.select()
      .columns(.all)
      .from(table)
      .where("id", .equal, id)
      .first(decoding: A.self)
      .mapExcept(requireSome("fetchId: \(table) : \(id)"))
  }
}

func insert<I, A>(
  to table: Table,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> (I) -> EitherIO<Error, A>
  where I: Encodable, A: Decodable
{
  { request in
    let promise = pool.eventLoopGroup.next().makePromise(of: A.self)
    do {
      promise.succeed(
        try pool.sqlDatabase.insert(into: table)
          .model(request)
          .returning(.all)
          .first(decoding: A.self)
          .mapExcept(requireSome("insert: \(table) : \(request)"))
          .run
          .perform()
          .unwrap()
      )
    } catch {
      promise.fail(error)
    }
    
    return .init(promise.futureResult)
  }
}

func update<U, A>(
  table: Table,
  on pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
) -> (U) -> EitherIO<Error, A>
where U: Encodable, U: Identifiable, U.ID: Encodable, A: Decodable
{
  { request in
    let promise = pool.eventLoopGroup.next().makePromise(of: A.self)
    do {
      promise.succeed(
        try pool.sqlDatabase.update(table)
          .where("id", .equal, request.id)
          .set(model: request)
          .returning(.all)
          .first(decoding: A.self)
          .mapExcept(requireSome("update: \(table) : \(request)"))
          .run
          .perform()
          .unwrap()
      )
    } catch {
      promise.fail(error)
    }
    
    return .init(promise.futureResult)
  }
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
