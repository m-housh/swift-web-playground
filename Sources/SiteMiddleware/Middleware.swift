import ApplicativeRouterHttpPipelineSupport
import DatabaseClient
import Logging
import Foundation
import HttpPipeline
import Prelude
import Router
import SharedModels

public func respondJson<A: Encodable>() -> (Conn<HeadersOpen, A>) -> IO<Conn<ResponseEnded, Data>> {
  { conn in
    let encoder = JSONEncoder()
    let data = try! encoder.encode(conn.data)
    
    return conn.map(const(data))
      |> writeHeader(.contentType(.json))
      >=> writeHeader(.contentLength(data.count))
      >=> closeHeaders
      >=> end
  }
}

func apiMiddleware(
  _ environment: ServerEnvironment
) -> Middleware<StatusLineOpen, ResponseEnded, UserRoute, Data> {
  { conn in
    let route = conn.data
    
    switch route {
    case .fetch:
      return environment.database
        .fetchUsers()
        .run
        .flatMap { errorOrUsers in
          switch errorOrUsers {
          case let .right(users):
            return conn.map(const(users))
              |> writeStatus(.ok)
              >=> respondJson()
            
          case .left(_):
            return conn.map(const([User]()))
              |> writeStatus(.internalServerError)
              >=> respondJson()
              
          }
        }
    case let .fetchOne(id: id):
      return environment.database
        .fetchUser(id)
        .run
        .flatMap { errorOrUser in
          switch errorOrUser {
          case let .right(user):
            return conn.map(const(user))
              |> writeStatus(.ok)
              >=> respondJson()
            
          case let .left(error):
            return conn.map(const(error.localizedDescription))
              |> writeStatus(.badRequest)
              >=> respondJson()
          }
        }
    case let .insert(model):
      return environment.database
        .insertUser(.init(name: model.name))
        .run
        .flatMap { errorOrUser in
          switch errorOrUser {
          case let .right(user):
            return conn.map(const(user))
              |> writeStatus(.ok)
              >=> respondJson()
          case let .left(error):
            return conn.map(const(error.localizedDescription))
              |> writeStatus(.badRequest)
              >=> respondJson()
          }
        }
    case let .update(id: _, update: update):
      return environment.database
        .updateUser(update)
        .run
        .flatMap { errorOrUpdate in
          switch errorOrUpdate {
          case let .right(user):
            return conn.map(const(user))
            |> writeStatus(.ok)
            >=> respondJson()
          case let .left(error):
            return conn.map(const(error.localizedDescription))
              |> writeStatus(.badRequest)
              >=> respondJson()
          }
        }
    case let .delete(id: id):
      struct Success: Codable { }
      return environment.database
        .deleteUser(id)
        .run
        .flatMap { errorOrSuccess in
          switch errorOrSuccess {
          case .right:
            return conn.map(const(Success()))
            |> writeStatus(.ok)
            >=> respondJson()
            
          case let .left(error):
            return conn.map(const(error.localizedDescription))
              |> writeStatus(.badRequest)
              >=> respondJson()
          }
        }
    }
  }
}

public func siteMiddleware(
  environment: ServerEnvironment
) -> Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> {
  
  requestLogger(
    logger: { string in
      var logger = Logger(label: "Route Logger")
      logger.logLevel = .debug
      logger.debug(.init(stringLiteral: string))
    },
    uuid: UUID.init
  ) <<<
  ApplicativeRouterHttpPipelineSupport.route(
    router: environment.router,
    notFound: writeStatus(.notFound) >=> respond(json: "{}")
  )
  <| apiMiddleware(environment)
}
