import ApplicativeRouter
import CasePaths
import Foundation
import NonEmpty
import Prelude

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Represents the routes that can be used in the `BasicCrudRouter`.  This allows some routes to be disabled when creating
/// a router.
public enum CRUDRouteType: CaseIterable, Equatable {
  case fetch, fetchOne, insert, update, delete
}

/// A basic crud router that can handle crud routes for a model.  It allows for custom insert and update types.
///
public struct BasicCrudRouter<Model, Insert, Update>
where Model: Identifiable, Insert: Codable, Update: Codable
{
  
  /// The router to use for the delete route.
  public var delete: Router<Route>?
  
  /// The router to use for the fetch route.
  public var fetch: Router<Route>?
  
  /// The router to use for the fetch by id route.
  public var fetchOne: Router<Route>?
  
  /// The router to use for the insert route.
  public var insert: Router<Route>?
  
  /// The router to use for the update route.
  public var update: Router<Route>?
  
  /// Create a new `BasicCrudRouter` with the given routers.
  ///
  /// - Parameters:
  ///   - delete: The router to use for the delete route.
  ///   - fetch: The router to use for the fetch route.
  ///   - fetchOne: The router to use for the fetch by id route.
  ///   - insert: The router to use for the insert route.
  ///   - update: The router to use for the update route.
  public init(
    delete: Router<Route>? = nil,
    fetch: Router<Route>? = nil,
    fetchOne: Router<Route>? = nil,
    insert: Router<Route>? = nil,
    update: Router<Route>? = nil
  ) {
    self.delete = delete
    self.fetch = fetch
    self.fetchOne = fetchOne
    self.insert = insert
    self.update = update
  }
  
  /// The routes that we can take / handle.
  public enum Route {
    case delete(id: Model.ID)
    case fetch
    case fetchOne(id: Model.ID)
    case insert(Insert)
    case update(id: Model.ID, update: Update)
  }
  
  /// Parses the router for the given `CRUDRouteType`
  ///
  /// - Parameters:
  ///   - routeType: The crud route type to return.
  private func _router(_ routeType: CRUDRouteType) -> Router<Route>? {
    switch routeType {
    case .delete:
      return self.delete
    case .fetch:
      return self.fetch
    case .fetchOne:
      return self.fetchOne
    case .insert:
      return self.insert
    case .update:
      return self.update
    }
  }
  
  /// Creates the actual router, defaults to using all the routes, but you can disable certain routes by not including them
  /// in the routes parameter when calling this method.
  ///
  /// - Parameters:
  ///   - routes: The routes for this router to handle, defaults to all routes.
  public func router(for routes: [CRUDRouteType] = .all) -> Router<Route> {
    routes.compactMap(_router)
      .reduce(.empty, <|>)
  }
}

extension BasicCrudRouter.Route: Equatable
where Model.ID: Equatable, Model.ID: Equatable, Insert: Equatable, Update: Equatable { }

extension BasicCrudRouter {
  
  /// Create a new `BasicCrudRouter` with the default routes from the `CrudRoute` type.
  ///
  /// - Parameters:
  ///   - pathComponents: The path components used for the routes.
  ///   - idIso: The partial isomorphism for the model id.
  ///   - decoder: The json decoder to use.
  ///   - encoder: The json encoder to use.
  public static func `default`(
    path pathComponents: NonEmptyArray<String>,
    idIso: PartialIso<String, Model.ID>,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) -> Self {
    BasicCrudRouter(
      delete: CrudRoute.delete(/Route.delete, path: pathComponents, idIso: idIso),
      fetch: CrudRoute.fetch(/Route.fetch, path: pathComponents),
      fetchOne: CrudRoute.fetchId(/Route.fetchOne, path: pathComponents, idIso: idIso),
      insert: CrudRoute.insert(/Route.insert, path: pathComponents, decoder: decoder, encoder: encoder),
      update: CrudRoute
        .update(/Route.update, path: pathComponents, idIso: idIso, decoder: decoder, encoder: encoder)
    )
  }
  
  /// Create a new `BasicCrudRouter` with the default routes from the `CrudRoute` type.
  ///
  /// - Parameters:
  ///   - pathComponents: The path components used for the routes.
  ///   - idIso: The partial isomorphism for the model id.
  ///   - decoder: The json decoder to use.
  ///   - encoder: The json encoder to use.
  public static func `default`(
    path pathComponents: String...,
    idIso: PartialIso<String, Model.ID>,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) -> Self {
    assert(pathComponents.count > 0, "No path components found")
    return .default(path: NonEmptyArray<String>(pathComponents)!, idIso: idIso, decoder: decoder, encoder: encoder)
  }
}

extension BasicCrudRouter where Model.ID == UUID {
  
  /// Create a new `BasicCrudRouter` with the default routes from the `CrudRoute` type.
  ///
  /// - Parameters:
  ///   - pathComponents: The path components used for the routes.
  ///   - decoder: The json decoder to use.
  ///   - encoder: The json encoder to use.
  public static func `default`(
    path pathComponents: NonEmptyArray<String>,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) -> Self {
    .default(path: pathComponents, idIso: .uuid, decoder: decoder, encoder: encoder)
  }
  
  /// Create a new `BasicCrudRouter` with the default routes from the `CrudRoute` type.
  ///
  /// - Parameters:
  ///   - pathComponents: The path components used for the routes.
  ///   - decoder: The json decoder to use.
  ///   - encoder: The json encoder to use.
  public static func `default`(
    path pathComponents: String...,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) -> Self {
    assert(pathComponents.count > 0, "No path components found")
    return .default(
      path: NonEmptyArray<String>(pathComponents)!,
      idIso: .uuid,
      decoder: decoder,
      encoder: encoder
    )
  }
}

/// Strips any leading "/" from the path.
///
/// - Parameters:
///   - path: The path to sanitize.
private func sanitizePath(_ path: String) -> String {
  if path.starts(with: "/") {
    // call ourself recursively until all leading "/" are removed.
    return sanitizePath(String(path.dropFirst()))
  }
  return path
}

/// Sanitize and parse the path components used in routes.
///
/// - Parameters:
///   - first: The first path component to sanitize and parse.
///   - rest: The other path components to sanitize and parse.
func parsePath(_ first: String, rest: ArraySlice<String>) -> Router<Void> {
  rest.reduce(lit(sanitizePath(first)), { $0 %> lit(sanitizePath($1)) })
}

/// Sanitize and parse the path components used in routes.
///
/// - Parameters:
///   - pathComponents: The path components to sanitize and parse.
func parsePath(_ pathComponents: NonEmptyArray<String>) -> Router<Void> {
  return parsePath(pathComponents.first, rest: pathComponents.suffix(from: 1))
}

extension Array where Element == CRUDRouteType {
  
  /// Convenience for creating an array of all the `CRUDRouteType`'s.
  public static var all: Self { CRUDRouteType.allCases }
}
