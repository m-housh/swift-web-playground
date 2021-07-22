import ApplicativeRouter
import CasePaths
import CrudRouter
import DatabaseClient
import Foundation
import NonEmpty
import Prelude
import SharedModels

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum ServerRoute: Equatable {
  
  public typealias FavoriteRouter = BasicCrudRouter<
    UserFavorite,
    DatabaseClient.InsertFavoriteRequest,
    UpdateFavoriteRequest
  >
  
  public typealias UserRouter = BasicCrudRouter<
    User,
    DatabaseClient.InsertUserRequest,
    UpdateUserRequest
  >
  
  public typealias UserRoute = UserRouter.Route

  case users(UserRoute)
  case favorites(FavoriteRoute)
  
  public enum FavoriteRoute: Equatable {
    case `default`(FavoriteRouter.Route)
    case fetch(User.ID?)
  }
  
  public struct UpdateUserRequest: Equatable, Codable {
    public var name: String?
    
    public init(name: String?) {
      self.name = name
    }
  }
  
  public struct UpdateFavoriteRequest: Equatable, Codable {
    public var description: String?
    
    public init(description: String?) {
      self.description = description
    }
  }
}

public func router(
  pathPrefix: NonEmptyArray<String>? = nil,
  decoder: JSONDecoder,
  encoder: JSONEncoder
) -> Router<ServerRoute> {

  let userPath: NonEmptyArray<String> = pathPrefix != nil ?
    pathPrefix! + ["users"] : .init(["users"])!
  
  let userRouter = ServerRoute.UserRouter.default(
    path: userPath,
    decoder: decoder,
    encoder: encoder
  )
  .router()
  
  let favoritePath: NonEmptyArray<String> = pathPrefix != nil ?
    pathPrefix! + ["favorites"] : .init(["favorites"])!
  
  let defaultFavoriteRouter = ServerRoute.FavoriteRouter.default(
    path: favoritePath,
    decoder: decoder,
    encoder: encoder
  )
  .router(for: [.delete, .fetchOne, .insert, .update])
  
  let favoriteRouter: Router<ServerRoute.FavoriteRoute> = [
    
    CrudRoute.fetch(
      /ServerRoute.FavoriteRoute.fetch,
       path: favoritePath,
       param: ("userId", opt(.uuid))
    ),
    
    .case(/ServerRoute.FavoriteRoute.default)
      <¢> defaultFavoriteRouter
    
  ].reduce(.empty, <|>)

  let routers: [Router<ServerRoute>] = [
    PartialIso.case(/ServerRoute.users)
      <¢> userRouter,
    
    PartialIso.case(/ServerRoute.favorites)
      <¢> favoriteRouter
  ]

  return routers.reduce(.empty, <|>)
}

public typealias FavoriteRouter = Router<ServerRoute.FavoriteRoute>
public typealias UserRouter = Router<ServerRoute.UserRoute>
