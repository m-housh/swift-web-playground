import ApplicativeRouter
import CasePaths
import Foundation
import NonEmpty
import Prelude

extension Router {

  /// Useful when embedding a router inside of another one.
  ///
  /// - Parameters:
  ///   - casePath: The case path to match the route on.
  ///   - next: The router used to parse / create the input to embed in the case path.
  public static func `case`<B>(
    _ casePath: CasePath<A, B>,
    chainingTo router: Router<B>
  ) -> Router {
    PartialIso.case(casePath)
      <¢> router
  }

  /// Useful when embedding a router inside of another one.
  ///
  /// - Parameters:
  ///   - casePath: The case path to match the route on.
  ///   - next: The router used to parse / create the input to embed in the case path.
  public static func `case`<B>(
    _ casePath: CasePath<A, B>,
    chainingTo router: @escaping () -> Router<B>
  ) -> Router {
    .case(casePath, chainingTo: router())
  }

  /// Convenience for creating a router out of an array of routers that do the actual request handling.
  ///
  /// - Parameters:
  ///    - routers: The routers responsible for handling the routing.
  public static func chaining<A>(_ routers: [Router<A>]) -> Router<A> {
    routers.reduce(.empty, <|>)
  }

  /// Convenience for creating a router out of an array of routers that do the actual request handling.
  ///
  /// - Parameters:
  ///    - routers: The routers responsible for handling the routing.
  public static func chaining<A>(_ routers: Router<A>...) -> Router<A> {
    chaining(routers)
  }

  /// Create a router that matches an incoming DELETE request.
  ///
  /// - Parameters:
  ///   - casePath: The case path to match the route on.
  ///   - path: Any potential path components to match the route against.
  ///   - router: The router used to parse / create the input to embed in the case path.
  public static func delete<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    chainingTo router: Router<B>
  ) -> Router {
    Router(casePath, at: path, method: .delete, chainingTo: router)
  }

  /// Create a router that matches an incoming DELETE request.
  ///
  /// - Parameters:
  ///   - casePath: The case path to match the route on.
  ///   - path: Any potential path components to match the route against.
  ///   - router: The router used to parse / create the input to embed in the case path.
  public static func delete<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    chainingTo router: @escaping () -> Router<B>
  ) -> Router {
    Router(casePath, at: path, method: .delete, chainingTo: router())
  }

  /// Create a router that matches an incoming GET request.
  ///
  /// - Parameters:
  ///   - casePath: The case path to match the route on.
  ///   - path: Any potential path components to match the route against.
  public static func get(
    _ casePath: CasePath<A, Void>,
    at path: NonEmptyArray<String>? = nil
  ) -> Router {
    Router(casePath, at: path, method: .get)
  }

  /// Create a router that matches an incoming GET request.
  ///
  /// - Parameters:
  ///   - casePath: The case path to match the route on.
  ///   - path: Any potential path components to match the route against.
  ///   - router: The router used to parse / create the input to embed in the case path.
  public static func get<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    chainingTo router: @escaping () -> Router<B>
  ) -> Router {
    Router(casePath, at: path, method: .get, chainingTo: router())
  }

  /// Create a router that matches an incoming GET request.
  ///
  /// - Parameters:
  ///   - casePath: The case path to match the route on.
  ///   - path: Any potential path components to match the route against.
  ///   - router: The router used to parse / create the input to embed in the case path.
  public static func get<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    chainingTo router: Router<B>
  ) -> Router {
    Router(casePath, at: path, method: .get, chainingTo: router)
  }

  /// Convenience for creating a router out of an array of routers that do the actual request handling.
  ///
  /// - Parameters:
  ///    - routers: The routers responsible for handling the routing.
  public static func matching<A>(_ routers: [Router<A>]) -> Router<A> {
    routers.reduce(.empty, <|>)
  }

  /// Convenience for creating a router out of an array of routers that do the actual request handling.
  ///
  /// - Parameters:
  ///    - routers: The routers responsible for handling the routing.
  public static func matching<A>(_ routers: Router<A>...) -> Router<A> {
    matching(routers)
  }

  /// Create a router that matches an incoming POST request.
  ///
  /// - Parameters:
  ///   - casePath: The case path to match the route on.
  ///   - path: Any potential path components to match the route against.
  ///   - router: The router used to parse / create the input to embed in the case path.
  public static func post<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    chainingTo router: @escaping () -> Router<B>
  ) -> Router {
    Router(casePath, at: path, method: .post, chainingTo: router())
  }

  /// Create a router that matches an incoming POST request.
  ///
  /// - Parameters:
  ///   - casePath: The case path to match the route on.
  ///   - path: Any potential path components to match the route against.
  ///   - router: The router used to parse / create the input to embed in the case path.
  public static func post<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    chainingTo router: Router<B>
  ) -> Router {
    Router(casePath, at: path, method: .post, chainingTo: router)
  }
}

/// A convenience for parsing a path parameter then chaining to a router.
///
/// - Parameters:
///   - parameter: The partial isomorphism to parse the path parameter.
///   - router: The next router in the chain.
public func pathParam<A, B>(
  _ parameter: PartialIso<String, A>,
  _ router: Router<B>
) -> Router<(A, B)> {
  pathParam(parameter) <%> router
}

/// A convenience for parsing a path parameter then chaining to a router.
///
/// - Parameters:
///   - parameter: The partial isomorphism to parse the path parameter.
///   - router: The next router in the chain.
public func pathParam<A, B>(
  _ parameter: PartialIso<String, A>,
  _ router: @escaping () -> Router<B>
) -> Router<(A, B)> {
  pathParam(parameter, router())
}

// MARK: - Helpers
extension Router {

  // Router currently does not have any public initializers, so keeping these internal.
  init<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    method: ApplicativeRouter.Method,
    chainingTo router: Router<B>
  ) {
    self = PartialIso.case(casePath)
      <¢> ApplicativeRouter.method(method)
      %> parsePath(path)
      %> router
      <% end
  }

  init(
    _ casePath: CasePath<A, Void>,
    at path: NonEmptyArray<String>? = nil,
    method: ApplicativeRouter.Method
  ) {
    self = PartialIso.case(casePath)
      <¢> ApplicativeRouter.method(method)
      %> parsePath(path)
      <% end
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
private func parsePath(_ first: String, rest: ArraySlice<String>) -> Router<Void> {
  rest.reduce(lit(sanitizePath(first)), { $0 %> lit(sanitizePath($1)) })
}

/// Sanitize and parse the path components used in routes.
///
/// - Parameters:
///   - pathComponents: The path components to sanitize and parse.
private func parsePath(_ pathComponents: NonEmptyArray<String>) -> Router<Void> {
  return parsePath(pathComponents.first, rest: pathComponents.suffix(from: 1))
}

/// Sanitize and parse the path components used in routes.
///
/// - Parameters:
///   - pathComponents: The path components to sanitize and parse, if available.
private func parsePath(_ pathComponents: NonEmptyArray<String>?) -> Router<Void> {
  guard let pathComponents = pathComponents else {
    return .empty
  }
  return parsePath(pathComponents)
}
