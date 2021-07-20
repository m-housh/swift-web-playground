import ApplicativeRouterHttpPipelineSupport
import DatabaseClient
import Either
import Logging
import Foundation
import HttpPipeline
import Prelude
import Router
import SharedModels

public func siteMiddleware(
  environment: ServerEnvironment,
  logger: Logger? = nil
) -> Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> {
  
  requestLogger(
    logger: { logger?.debug(.init(stringLiteral: $0)) },
    uuid: UUID.init
  )
  <<< ApplicativeRouterHttpPipelineSupport.route(
    router: environment.router,
    notFound: writeStatus(.notFound) >=> respond(json: "{}")
  )
  <| apiMiddleware(environment, logger)
}

private func apiMiddleware(
  _ environment: ServerEnvironment,
  _ logger: Logger?
) -> Middleware<StatusLineOpen, ResponseEnded, UserRoute, Data> {
  { conn in
    let route = conn.data
    
    switch route {
    case .fetch:
      logger?.debug("fetching users")
      return environment.database
        .fetchUsers()
        .run
        .flatMap(respond(on: conn))

    case let .fetchOne(id: id):
      logger?.debug("fetching user.id: \(id)")
      return environment.database
        .fetchUser(id)
        .run
        .flatMap(respond(on: conn))

    case let .insert(model):
      logger?.debug("inserting user: \(model)")
      return environment.database
        .insertUser(.init(name: model.name))
        .run
        .flatMap(respond(on: conn))

    case let .update(id: id, update: update):
      logger?.debug("updating user.id: \(id)")
      logger?.debug("with updates: \(update)")
      return environment.database
        .updateUser(.init(id: id, name: update.name))
        .run
        .flatMap(respond(on: conn))

    case let .delete(id: id):
      logger?.debug("deleting user.id: \(id)")
      return environment.database
        .deleteUser(id)
        .run
        .flatMap(respond(on: conn))
    }
  }
}

private func respond<A>(
  on conn: Conn<StatusLineOpen, UserRoute>
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

private func respond(
  on conn: Conn<StatusLineOpen, UserRoute>
) -> (Either<Error, Void>) -> IO<Conn<ResponseEnded, Data>> {
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
