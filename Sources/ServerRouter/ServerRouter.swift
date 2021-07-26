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

  // More routes could be added here.
  .matching(

    // Handle the /users routes.
    .case(/ApiRoute.users) {
      makeUserRouter(
        path: pathPrefix.appending("users"),
        decoder: decoder,
        encoder: encoder
      )
    },

    // Handle the /favorites routes.
    .case(/ApiRoute.favorites) {
      makeFavoriteRouter(
        path: pathPrefix.appending("favorites"),
        decoder: decoder,
        encoder: encoder
      )
    }
  )
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
  .matching(
    .delete(/ApiRoute.UsersRoute.delete, at: path) {
      pathParam(.uuid)
    },
    .get(/ApiRoute.UsersRoute.fetch, at: path),
    .get(/ApiRoute.UsersRoute.fetchId(id:), at: path) {
      pathParam(.uuid)
    },
    .post(/ApiRoute.UsersRoute.insert, at: path) {
      jsonBody(ApiRoute.UsersRoute.InsertRequest.self, encoder: encoder, decoder: decoder)
    },
    .post(/ApiRoute.UsersRoute.update, at: path) {
      pathParam(.uuid) {
        jsonBody(ApiRoute.UsersRoute.UpdateRequest.self, encoder: encoder, decoder: decoder)
      }
    }
  )
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
  .matching(
    .delete(/ApiRoute.FavoritesRoute.delete, at: path) {
      pathParam(.uuid)
    },
    .get(/ApiRoute.FavoritesRoute.fetch(userId:), at: path) {
      queryParam("userId", opt(.uuid))
    },
    .get(/ApiRoute.FavoritesRoute.fetchId(id:), at: path) {
      pathParam(.uuid)
    },
    .post(/ApiRoute.FavoritesRoute.insert, at: path) {
      jsonBody(ApiRoute.FavoritesRoute.InsertRequest.self, encoder: encoder, decoder: decoder)
    },
    .post(/ApiRoute.FavoritesRoute.update, at: path) {
      pathParam(.uuid) {
        jsonBody(ApiRoute.FavoritesRoute.UpdateRequest.self, encoder: encoder, decoder: decoder)
      }
    }
  )
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
