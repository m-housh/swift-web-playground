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
  
  public typealias FavoriteRouter = CrudRouter<
    UserFavorite,
    DatabaseClient.InsertFavoriteRequest,
    UpdateFavoriteRequest
  >
  
  public typealias UserRouter = CrudRouter<
    User,
    DatabaseClient.InsertUserRequest,
    UpdateUserRequest
  >

//  public typealias FavoriteRoute = FavoriteRouter.Route

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
  decoder: JSONDecoder,
  encoder: JSONEncoder
) -> Router<ServerRoute> {

  let userRouter = ServerRoute.UserRouter.default(
    path: ["users"],
    decoder: decoder,
    encoder: encoder
  )
  .router()
  
  let defaultFavoriteRouter = ServerRoute.FavoriteRouter.default(
    path: ["favorites"],
    decoder: decoder,
    encoder: encoder
  )
  .router(for: [.delete, .fetchOne, .insert, .update])
  
  let favoriteRouter: Router<ServerRoute.FavoriteRoute> = [
    
    .case(/ServerRoute.FavoriteRoute.fetch)
      <¢> get
      %> lit("favorites") %> queryParam("userId", opt(.uuid))
      <% end,
    
    .case(/ServerRoute.FavoriteRoute.default)
      <¢> defaultFavoriteRouter
    
  ].reduce(.empty, <|>)
  
//  var favoriteRouter = ServerRoute.FavoriteRouter(
//    fetch: .case(/ServerRoute.FavoriteRoute.fetch)
//      <¢> get  // httpMethod
//      %> lit("favorites") %> queryParam("userId", opt(.uuid))
//      <% end
//  ).router(for: [.fetchOne])
//
  
//  let favoriteRouter = FavoriteRouter("favorites", encoder: encoder, decoder: decoder)

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

//extension FavoriteRouter {
//
//  init(
//    _ path: String...,
//    encoder jsonEncoder: JSONEncoder = .init(),
//    decoder jsonDecoder: JSONDecoder = .init()
//  ) {
//    self = crudRouter(
//      path,
//      id: .uuid,
//      encoder: jsonEncoder,
//      decoder: jsonDecoder
//    )
//  }
//}

//extension UserRouter {
//
//  init(
//    _ path: String...,
//    encoder jsonEncoder: JSONEncoder = .init(),
//    decoder jsonDecoder: JSONDecoder = .init()
//  ) {
//    self = crudRouter(
//      path,
//      id: .uuid,
//      encoder: jsonEncoder,
//      decoder: jsonDecoder
//    )
//  }
//}

//private func sanitizePath(_ path: String) -> String {
//  if path.starts(with: "/") {
//    return String(path.dropFirst())
//  }
//  return path
//}
//
//private func parsePath(_ first: String, rest: ArraySlice<String>) -> Router<Void> {
//  rest.reduce(lit(first), { $0 %> lit($1) })
//}
