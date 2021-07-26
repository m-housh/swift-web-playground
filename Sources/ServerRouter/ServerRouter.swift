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
  let favoritesPath = pathPrefix.appending("favorites")

  // More routes could be added here.
  return .chaining(

    // Handle the /users routes.
    .case(/ApiRoute.users) {
      .chaining(
        .delete(/ApiRoute.UsersRoute.delete, at: usersPath) {
          pathParam(.uuid)
        },
        .get(/ApiRoute.UsersRoute.fetch, at: usersPath),
        .get(/ApiRoute.UsersRoute.fetchId(id:), at: usersPath) {
          pathParam(.uuid)
        },
        .post(/ApiRoute.UsersRoute.insert, at: usersPath) {
          jsonBody(ApiRoute.UsersRoute.InsertRequest.self, encoder: encoder, decoder: decoder)
        },
        .post(/ApiRoute.UsersRoute.update, at: usersPath) {
          pathParam(.uuid) {
            jsonBody(ApiRoute.UsersRoute.UpdateRequest.self, encoder: encoder, decoder: decoder)
          }
        }
      )
    },

    // Handle the /favorites routes.
    .case(/ApiRoute.favorites) {
      .chaining(
        .delete(/ApiRoute.FavoritesRoute.delete, at: favoritesPath) {
          pathParam(.uuid)
        },
        .get(/ApiRoute.FavoritesRoute.fetch(userId:), at: favoritesPath) {
          queryParam("userId", opt(.uuid))
        },
        .get(/ApiRoute.FavoritesRoute.fetchId(id:), at: favoritesPath) {
          pathParam(.uuid)
        },
        .post(/ApiRoute.FavoritesRoute.insert, at: favoritesPath) {
          jsonBody(ApiRoute.FavoritesRoute.InsertRequest.self, encoder: encoder, decoder: decoder)
        },
        .post(/ApiRoute.FavoritesRoute.update, at: favoritesPath) {
          pathParam(.uuid) {
            jsonBody(ApiRoute.FavoritesRoute.UpdateRequest.self, encoder: encoder, decoder: decoder)
          }
        }
      )
    }
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
