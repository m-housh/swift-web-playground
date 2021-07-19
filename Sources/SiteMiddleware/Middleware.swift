import DatabaseClient
import Foundation
import HttpPipeline
import Prelude
import Router
import SharedModels

public func respondJson<A: Encodable>(
  _ encoding: A.Type = A.self
) -> (Conn<HeadersOpen, A>) -> IO<Conn<ResponseEnded, Data>> {
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

struct ApiInput {
  let database: DatabaseClient
  let route: UserRoute
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
              >=> respondJson([User].self)
            
          case .left(_):
            return conn.map(const([User]()))
              |> writeStatus(.internalServerError)
              >=> respondJson([User].self)
              
          }
        }
    case .fetchOne(id: let id):
      return environment.database
        .fetchUser(id)
        .run
        .flatMap { errorOrUser in
          switch errorOrUser {
          case let .right(user):
            return conn.map(const(user))
              |> writeStatus(.ok)
              >=> respondJson(User.self)
            
          case let .left(error):
            return conn.map(const(error.localizedDescription))
              |> writeStatus(.badRequest)
              >=> respondJson()
          }
        }
    case .insert(_):
      <#code#>
    case .update(id: let id, update: let update):
      <#code#>
    case .delete(id: let id):
      <#code#>
    }
  }
}
