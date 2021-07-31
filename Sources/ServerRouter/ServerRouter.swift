import ApplicativeRouter
import CasePaths
import Foundation
import NonEmpty
import Prelude
import RouterUtils
import SharedModels

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Creates the final router used for matching all the routes we know how to handle in the application.  It can be provided
/// an optional path prefix to match on.  The path prefix is expected to be either nil or a non-empty array of strings.
///
/// If you wanted to prefix the routes to match `/api/v1/{ route }`.
/// ```
///   let serverRouter = router(pathPrefix: .init("api", "v1"), decoder: .init(), encoder: .init())
/// ```
///
///  - Parameters:
///   - pathPrefix: An optional path prefix to match on.
///   - decoder: The json decoder used for decoding data.
///   - encoder: The json encoder used for encoding data.
public func router(
  pathPrefix: NonEmptyArray<String>? = nil,
  decoder: JSONDecoder,
  encoder: JSONEncoder
) -> Router<ApiRoute> {

  let usersPath = pathPrefix.appending("users")

  // Have to specifiy the type before calling the method for it to work on Linux,
  // in swift 5.3 at least.  It works without on macOS, which is a cleaner looking syntax.

  let usersRouter: Router<ApiRoute.UsersRoute> = .routes(
    Router<ApiRoute.UsersRoute>.delete().path(usersPath)
      .pathParam(.uuid)
      .case(/ApiRoute.UsersRoute.delete(id:))
      .end(),

    Router<ApiRoute.UsersRoute>.get().path(usersPath)
      .case(/ApiRoute.UsersRoute.fetch)
      .end(),

    Router<ApiRoute.UsersRoute>.get().path(usersPath)
      .pathParam(.uuid)
      .case(/ApiRoute.UsersRoute.fetchId(id:))
      .end(),

    Router<ApiRoute.UsersRoute>.post().path(usersPath)
      .jsonBody(ApiRoute.UsersRoute.InsertRequest.self, encoder: encoder, decoder: decoder)
      .case(/ApiRoute.UsersRoute.insert)
      .end(),

    Router<ApiRoute.UsersRoute>.post().path(usersPath)
      .tuple(
        pathParam(.uuid),
        jsonBody(ApiRoute.UsersRoute.UpdateRequest.self, encoder: encoder, decoder: decoder)
      )
      .case(/ApiRoute.UsersRoute.update(id:update:))
      .end()
  )

  let favoritesPath = pathPrefix.appending("favorites")

  // Have to specifiy the type before calling the method for it to work on Linux,
  // in swift 5.3 at least.  It works without on macOS, which is a cleaner looking syntax.

  let favoritesRouter: Router<ApiRoute.FavoritesRoute> = .routes(
    Router<ApiRoute.FavoritesRoute>.delete().path(favoritesPath)
      .pathParam(.uuid)
      .case(/ApiRoute.FavoritesRoute.delete(id:))
      .end(),
    Router<ApiRoute.FavoritesRoute>.get().path(favoritesPath)
      .queryParam("userId", opt(.uuid))
      .case(/ApiRoute.FavoritesRoute.fetch(userId:))
      .end(),
    Router<ApiRoute.FavoritesRoute>.get().path(favoritesPath)
      .pathParam(.uuid)
      .case(/ApiRoute.FavoritesRoute.fetchId(id:))
      .end(),
    Router<ApiRoute.FavoritesRoute>.post().path(favoritesPath)
      .jsonBody(ApiRoute.FavoritesRoute.InsertRequest.self, encoder: encoder, decoder: decoder)
      .case(/ApiRoute.FavoritesRoute.insert)
      .end(),
    Router<ApiRoute.FavoritesRoute>.post().path(favoritesPath)
      .tuple(
        pathParam(.uuid),
        jsonBody(ApiRoute.FavoritesRoute.UpdateRequest.self, encoder: encoder, decoder: decoder)
      )
      .case(/ApiRoute.FavoritesRoute.update(id:update:))
      .end()
  )

  return Router<ApiRoute>.routes(
    Router<ApiRoute>.case(/ApiRoute.users, chainingTo: usersRouter),
    Router<ApiRoute>.case(/ApiRoute.favorites, chainingTo: favoritesRouter)
  )
}

// MARK: - Helpers

extension NonEmpty where Collection == [String] {

  func appending(_ element: String) -> Self {
    var elements = self.rawValue
    elements.append(element)
    return NonEmptyArray<String>(elements)!
  }
}

extension Optional where Wrapped == NonEmptyArray<String> {
  func appending(_ element: String) -> NonEmptyArray<String> {
    guard let strong = self else {
      return .init(element)
    }
    return strong.appending(element)
  }
}

#if DEBUG

extension Router where A == ApiRoute {
  
  public static let testing = router(
    pathPrefix: .init("api"),
    decoder: .init(),
    encoder: .init()
  )
}
#endif
