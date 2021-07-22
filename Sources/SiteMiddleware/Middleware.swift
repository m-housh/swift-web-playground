import ApplicativeRouterHttpPipelineSupport
import DatabaseClient
import Either
import Foundation
import HttpPipeline
import Logging
import Prelude
import ServerRouter
import SharedModels

/// Creates the full middleware suite that is responsible for parsing and responding to incoming request connections.
/// This combines a request logging middleware that will log incoming requests / routes, not-found middleware for handling
/// requests at paths that we don't accept / no how to handle, and the api-middleware that is used for interactions between the database.
///
/// - Parameters:
///    - environment: The server environment values.
///    - logger: An optional logger used for debugging and logging incoming requests.
public func siteMiddleware(
  environment: ServerEnvironment,
  logger: Logger? = nil
) -> Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> {

  requestLogger(
    logger: { logger?.debug(.init(stringLiteral: $0)) },
    uuid: UUID.init
  )
  <<< route(
    router: environment.router,
    notFound: writeStatus(.notFound) >=> respond(json: "{}")
  )
  <| apiMiddleware(environment, logger)
}

/// Handle's the parsed routes, and interacts with the database to return the appropriate response to the client.
/// Adding new routes to the `ServerRoute` requires them to be handled here or there will be compile errors,
/// which is one of the advantages.
///
/// - Parameters:
///    - environment: The server environment values.
///    - logger: An optional logger used for debugging.
private func apiMiddleware(
  _ environment: ServerEnvironment,
  _ logger: Logger?
) -> Middleware<StatusLineOpen, ResponseEnded, ServerRoute, Data> {
  { conn in
    let route = conn.data

    switch route {
    case let .favorites(.fetch(userId)):
      logger?.debug("fetching favorites: \(String(describing: userId))")
      return environment.database
        .fetchFavorites(userId)
        .run
        .flatMap(respond(on: conn))

    case .users(.fetch):
      logger?.debug("fetching users")
      return environment.database
        .fetchUsers()
        .run
        .flatMap(respond(on: conn))

    case let .favorites(.default(.fetchOne(id: id))):
      logger?.debug("fetching favorites.id: \(id)")
      return environment.database
        .fetchFavorite(id)
        .run
        .flatMap(respond(on: conn))

    case let .users(.fetchOne(id: id)):
      logger?.debug("fetching user.id: \(id)")
      return environment.database
        .fetchUser(id)
        .run
        .flatMap(respond(on: conn))

    case let .favorites(.default(.insert(model))):
      logger?.debug("inserting favorites: \(model)")
      return environment.database
        .insertFavorite(model)
        .run
        .flatMap(respond(on: conn))

    case let .users(.insert(model)):
      logger?.debug("inserting user: \(model)")
      return environment.database
        .insertUser(model)
        .run
        .flatMap(respond(on: conn))

    case let .favorites(.default(.update(id: id, update: update))):
      logger?.debug("updating favorite.id: \(id)")
      logger?.debug("with updates: \(update)")
      return environment.database
        .updateFavorite(.init(id: id, description: update.description))
        .run
        .flatMap(respond(on: conn))

    case let .users(.update(id: id, update: update)):
      logger?.debug("updating user.id: \(id)")
      logger?.debug("with updates: \(update)")
      return environment.database
        .updateUser(.init(id: id, name: update.name))
        .run
        .flatMap(respond(on: conn))

    case let .favorites(.default(.delete(id: id))):
      logger?.debug("deleting favorite.id: \(id)")
      return environment.database
        .deleteFavorite(id)
        .run
        .flatMap(respond(on: conn))

    case let .users(.delete(id: id)):
      logger?.debug("deleting user.id: \(id)")
      return environment.database
        .deleteUser(id)
        .run
        .flatMap(respond(on: conn))
      
    case .favorites(.default(.fetch)):
      logger?.debug("WE SHOULD NOT HIT THIS ROUTE!")
      return conn.map(const(()))
        |> writeStatus(.internalServerError)
        >=> respond(text: "Invalid route")
    }
  }
}

/// Responsible for responding to incoming requests and transforming errors to `ApiError`'s.
///
/// - Parameters:
///   - conn: The incoming connection used to respond.
private func respond<A>(
  on conn: Conn<StatusLineOpen, ServerRoute>
) -> (Either<Error, A>) -> IO<Conn<ResponseEnded, Data>>
where A: Encodable
{
  { (eitherErrorOrOther: Either<Error, A>) -> IO<Conn<ResponseEnded, Data>> in
    switch eitherErrorOrOther {
    case let .left(error):
      return conn.map(const(ApiError(error: error)))
        |> writeStatus(.internalServerError)
        >=> respondJson()

    case let .right(value):
      return conn.map(const(value))
        |> writeStatus(.ok)
        >=> respondJson()
    }
  }
}

/// Responsible for responding to incoming requests and transforming errors to `ApiError`'s.
///
/// - Parameters:
///   - conn: The incoming connection used to respond.
private func respond(
  on conn: Conn<StatusLineOpen, ServerRoute>
) -> (Either<Error, Void>) -> IO<Conn<ResponseEnded, Data>>
{
  { (eitherErrorOrOther: Either<Error, Void>) -> IO<Conn<ResponseEnded, Data>> in
    switch eitherErrorOrOther {
    case let .left(error):
      return conn.map(const(ApiError(error: error)))
        |> writeStatus(.internalServerError)
        >=> respondJson()

    case .right:
      return conn.map(const(""))
        |> writeStatus(.ok)
        >=> respondJson()
    }
  }
}
