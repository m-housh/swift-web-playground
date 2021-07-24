import ApplicativeRouter
import CasePaths
import Foundation
import NonEmpty
import Prelude

/// Represents the routes that can be used in the `CrudRouter`.  This allows some routes to be disabled when creating
/// a router.
public enum CrudRouteType: CaseIterable, Equatable {

  /// The delete route.
  case delete

  /// The fetch route.
  case fetch

  /// The fetch by id route.
  case fetchId

  /// The insert route.
  case insert

  /// The update route.
  case update
}

/// Holds on to common CRUD routes and can create a `Router` based on the supplied routes.  It also has the ability to disable / skip routes,
/// even if they are supplied at initialization, when calling the `CrudRouter<Route>.router(for:)` method to create the actual `Router`
public struct CrudRouter<Route> {

  /// The router to use for the delete route.
  public var delete: Router<Route>?

  /// The router to use for the fetch route.
  public var fetch: Router<Route>?

  /// The router to use for the fetch by id route.
  public var fetchId: Router<Route>?

  /// The router to use for the insert route.
  public var insert: Router<Route>?

  /// The router to use for the update route.
  public var update: Router<Route>?

  /// Create a new `CrudRouterEnvelope` with the given routers.
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
    self.fetchId = fetchOne
    self.insert = insert
    self.update = update
  }

  /// Parses the router for the given `CRUDRouteType`
  ///
  /// - Parameters:
  ///   - routeType: The crud route type to return.
  private func _router(_ routeType: CrudRouteType) -> Router<Route>? {
    switch routeType {
    case .delete:
      return self.delete
    case .fetch:
      return self.fetch
    case .fetchId:
      return self.fetchId
    case .insert:
      return self.insert
    case .update:
      return self.update
    }
  }

  /// Creates the actual router, defaults to using all the routes, but you can disable certain routes by not including them
  /// in the routes parameter when calling this method, or if the router is `nil` for a given router type.
  ///
  /// - Parameters:
  ///   - routes: The routes for this router to handle, defaults to all routes.
  public func router(for routes: [CrudRouteType] = .all) -> Router<Route> {
    routes.compactMap(_router)
      .reduce(.empty, <|>)
  }
}

extension Array where Element == CrudRouteType {

  /// Convenience for creating an array of all the `CRUDRouteType`'s.
  public static var all: Self { CrudRouteType.allCases }
}
