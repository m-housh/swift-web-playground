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

public func router(
  pathPrefix: NonEmptyArray<String>? = nil,
  decoder: JSONDecoder,
  encoder: JSONEncoder
) -> Router<ApiRoute> {

  let userPath: NonEmptyArray<String> =
    pathPrefix != nil
    ? pathPrefix!.appending("users")
    : .init("users")

  let userRouter = makeUserRouter(path: userPath, decoder: decoder, encoder: encoder)

  let favoritePath: NonEmptyArray<String> =
    pathPrefix != nil
    ? pathPrefix!.appending("favorites")
    : .init("favorites")

  let favoriteRouter = makeFavoriteRouter(path: favoritePath, decoder: decoder, encoder: encoder)

  let routers: [Router<ApiRoute>] = [
    .case(/ApiRoute.users)
      <¢> userRouter,

    .case(/ApiRoute.favorites)
      <¢> favoriteRouter,
  ]

  return routers.reduce(.empty, <|>)
}

private func makeUserRouter(
  path: NonEmptyArray<String>,
  decoder: JSONDecoder,
  encoder: JSONEncoder
) -> Router<ApiRoute.UsersRoute> {
  CrudRouter(
    delete: .delete(/ApiRoute.UsersRoute.delete, path: path, idIso: .uuid),
    fetch: .fetch(/ApiRoute.UsersRoute.fetch, path: path),
    fetchOne: .fetchId(/ApiRoute.UsersRoute.fetchId(id:), path: path, idIso: .uuid),
    insert: .insert(
      /ApiRoute.UsersRoute.insert,
      path: path,
      decoder: decoder,
      encoder: encoder
    ),
    update: .update(
      /ApiRoute.UsersRoute.update,
      path: path,
      idIso: .uuid,
      decoder: decoder,
      encoder: encoder
    )
  )
  .router()
}

private func makeFavoriteRouter(
  path: NonEmptyArray<String>,
  decoder: JSONDecoder,
  encoder: JSONEncoder
) -> Router<ApiRoute.FavoritesRoute> {
  CrudRouter(
    delete: .delete(/ApiRoute.FavoritesRoute.delete, path: path, idIso: .uuid),
    fetch: .fetch(
      /ApiRoute.FavoritesRoute.fetch(userId:),
      path: path,
      param: (key: "userId", iso: opt(.uuid))
    ),
    fetchOne: .fetchId(/ApiRoute.FavoritesRoute.fetchId(id:), path: path, idIso: .uuid),
    insert: .insert(
      /ApiRoute.FavoritesRoute.insert,
      path: path,
      decoder: decoder,
      encoder: encoder
    ),
    update: .update(
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
