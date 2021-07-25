import ApplicativeRouter
import CasePaths
import CrudRouter
import Foundation
import NonEmpty
import Prelude
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

  // More routes could be added here.
  let routers: [Router<ApiRoute>] = [

    // Handle the /users routes.
    .case(/ApiRoute.users)
      <¢> makeUserRouter(
        path: pathPrefix.appending("users"),
        decoder: decoder,
        encoder: encoder
      ),

    // Handle the /favorites routes.
    .case(/ApiRoute.favorites)
      <¢> makeFavoriteRouter(
        path: pathPrefix.appending("favorites"),
        decoder: decoder,
        encoder: encoder
      ),
  ]

  return routers.reduce(.empty, <|>)
}

/// Creates the router that handles all the CRUD routes for the `/users` routes.
///
/// - Parameters:
///   - path: The path to match on, should be fully put together with the prefix if applicable.
///   - decoder: The json decoder to use.
///   - encoder: The json encoder to use.
private func makeUserRouter(
  path: NonEmptyArray<String>,
  decoder: JSONDecoder,
  encoder: JSONEncoder
) -> Router<ApiRoute.UsersRoute> {
  CrudRouter(
    delete: Router.delete(/ApiRoute.UsersRoute.delete, path: path, idIso: .uuid),
    fetch: Router.fetch(/ApiRoute.UsersRoute.fetch, path: path),
    fetchOne: Router.fetchId(/ApiRoute.UsersRoute.fetchId(id:), path: path, idIso: .uuid),
    insert: Router.insert(
      /ApiRoute.UsersRoute.insert,
      path: path,
      decoder: decoder,
      encoder: encoder
    ),
    update: Router.update(
      /ApiRoute.UsersRoute.update,
      path: path,
      idIso: .uuid,
      decoder: decoder,
      encoder: encoder
    )
  )
  .router()
}

/// Creates the router that handles all the CRUD routes for the `/favorites` routes.
///
/// - Parameters:
///   - path: The path to match on, should be fully put together with the prefix if applicable.
///   - decoder: The json decoder to use.
///   - encoder: The json encoder to use.
private func makeFavoriteRouter(
  path: NonEmptyArray<String>,
  decoder: JSONDecoder,
  encoder: JSONEncoder
) -> Router<ApiRoute.FavoritesRoute> {
  CrudRouter(
    delete: Router.delete(/ApiRoute.FavoritesRoute.delete, path: path, idIso: .uuid),
    fetch: Router.fetch(
      /ApiRoute.FavoritesRoute.fetch(userId:),
      path: path,
      param: (key: "userId", iso: opt(.uuid))
    ),
    fetchOne: Router.fetchId(/ApiRoute.FavoritesRoute.fetchId(id:), path: path, idIso: .uuid),
    insert: Router.insert(
      /ApiRoute.FavoritesRoute.insert,
      path: path,
      decoder: decoder,
      encoder: encoder
    ),
    update: Router.update(
      /ApiRoute.FavoritesRoute.update,
      path: path,
      idIso: .uuid,
      decoder: decoder,
      encoder: encoder
    )
  )
  .router()
}

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
