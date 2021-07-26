import ApplicativeRouter
import CasePaths
import Foundation
import NonEmpty
import Prelude

public extension Router {
  
  static func `case`<B>(
    _ casePath: CasePath<A, B>,
    params: Router<B>
  ) -> Router {
    PartialIso.case(casePath)
      <¢> params
  }
  
  static func `case`<B>(
    _ casePath: CasePath<A, B>,
    params: @escaping () -> Router<B>
  ) -> Router {
    .case(casePath, params: params())
  }
  
  static func delete<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    params: Router<B>
  ) -> Router {
    .init(casePath, at: path, method: .delete, params: params)
  }
  
  static func delete<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    params: @escaping () -> Router<B>
  ) -> Router {
    .init(casePath, at: path, method: .delete, params: params())
  }
  
  static func get(
    _ casePath: CasePath<A, Void>,
    at path: NonEmptyArray<String>? = nil
  ) -> Router {
    .init(casePath, at: path, method: .get)
  }
  
  static func get<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    params: @escaping () -> Router<B>
  ) -> Router {
    .init(casePath, at: path, method: .get, params: params())
  }
  
  static func get<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    params: Router<B>
  ) -> Router {
    .init(casePath, at: path, method: .get, params: params)
  }
  
  static func post<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    params: @escaping () -> Router<B>
  ) -> Router {
    .init(casePath, at: path, method: .post, params: params())
  }
  
  static func post<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    params: Router<B>
  ) -> Router {
    .init(casePath, at: path, method: .post, params: params)
  }

  static func matching<A>(_ routers: [Router<A>]) -> Router<A> {
    routers.reduce(.empty, <|>)
  }

  static func matching<A>(_ routers: Router<A>...) -> Router<A> {
    matching(routers)
  }
}

// MARK: - Helpers
extension Router {
  
  // Router currently does not have any public initializers, so keep this internal.
  init<B>(
    _ casePath: CasePath<A, B>,
    at path: NonEmptyArray<String>? = nil,
    method: ApplicativeRouter.Method,
    params: Router<B>
  ) {
    self = PartialIso.case(casePath)
      <¢> ApplicativeRouter.method(method)
      %> parsePath(path)
      %> params
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

private func parsePath(_ pathComponents: NonEmptyArray<String>?) -> Router<Void> {
  guard let pathComponents = pathComponents else {
    return .empty
  }
  return parsePath(pathComponents)
}

