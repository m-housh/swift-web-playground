import ApplicativeRouter
import CasePaths
import CrudRouter
import DatabaseClient
import Foundation
import Prelude
import SharedModels

#if canImport(FoundationNetworking)
  import FoundationNetworking
  import SharedModels
  import DatabaseClient
#endif

public enum ServerRoute: Equatable {

  public typealias FavoriteRoute = CRUDRoute<
    UserFavorite,
    DatabaseClient.InsertFavoriteRequest,
    DatabaseClient.UpdateFavoriteRequest
  >

  public typealias UserRoute = CRUDRoute<
    User,
    DatabaseClient.InsertUserRequest,
    DatabaseClient.UpdateUserRequest
  >

  case users(UserRoute)
  case favorites(FavoriteRoute)
}

public func router(
  decoder: JSONDecoder,
  encoder: JSONEncoder
) -> Router<ServerRoute> {

  let userRouter = UserRouter("users", encoder: encoder, decoder: decoder)
  let favoriteRouter = FavoriteRouter("favorites", encoder: encoder, decoder: decoder)

  let routers: [Router<ServerRoute>] = [
    PartialIso.case(/ServerRoute.users)
      <¢> userRouter,

    PartialIso.case(/ServerRoute.favorites)
      <¢> favoriteRouter,
  ]

  return routers.reduce(.empty, <|>)
}

public typealias FavoriteRouter = Router<ServerRoute.FavoriteRoute>
public typealias UserRouter = Router<ServerRoute.UserRoute>

extension FavoriteRouter {

  public init(
    _ path: String...,
    encoder jsonEncoder: JSONEncoder = .init(),
    decoder jsonDecoder: JSONDecoder = .init()
  ) {
    self = crudRouter(
      path,
      id: .uuid,
      encoder: jsonEncoder,
      decoder: jsonDecoder
    )
  }
}

extension UserRouter {

  public init(
    _ path: String...,
    encoder jsonEncoder: JSONEncoder = .init(),
    decoder jsonDecoder: JSONDecoder = .init()
  ) {
    self = crudRouter(
      path,
      id: .uuid,
      encoder: jsonEncoder,
      decoder: jsonDecoder
    )
  }
}
