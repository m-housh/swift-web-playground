import ApplicativeRouter
import CasePaths
import Foundation
import NonEmpty
import Prelude

/// Extends the router type with default crud operations. And is convenient with building a router that combines multiple
/// routers.
extension Router {

  /// Create a router that matches on  DELETE /{{ path }}/:id
  ///
  /// - Parameters:
  ///   - casePath: The case path used for the route.
  ///   - pathComponents: The path components used in the route.
  ///   - idIso: The partial isomorphisim used to parse the `ID`.
  public static func delete<ID>(
    _ casePath: CasePath<A, ID>,
    path pathComponents: NonEmptyArray<String>,
    idIso: PartialIso<String, ID>
  ) -> Router {
    .case(casePath)
      <¢> ApplicativeRouter.delete
      %> parsePath(pathComponents)
      %> pathParam(idIso)
      <% end
  }

  /// Create a router that matches on  GET /{{ path }}
  ///
  /// - Parameters:
  ///   - casePath: The case path used for the route.
  ///   - pathComponents: The path components used in the route.
  public static func fetch(
    _ casePath: CasePath<A, Void>,
    path pathComponents: NonEmptyArray<String>
  ) -> Router {
    .case(casePath)
      <¢> get  // httpMethod
      %> parsePath(pathComponents)
      <% end
  }

  /// Create a router that matches on single query parameter
  ///
  /// GET /{{ path }}?{{ key }}=:iso
  ///
  /// - Parameters:
  ///   - casePath: The case path used for the route.
  ///   - pathComponents: The path components used in the route.
  ///   - param: The key and partial isomorphisim used to parse the query parameter.
  public static func fetch<Param>(
    _ casePath: CasePath<A, Param>,
    path pathComponents: NonEmptyArray<String>,
    param: (key: String, iso: PartialIso<String?, Param>)
  ) -> Router {
    .case(casePath)
      <¢> get  // httpMethod
      %> parsePath(pathComponents)
      %> queryParam(param.key, param.iso)
      <% end
  }

  /// Create a router that matches on `Codable` query parameters
  ///
  /// GET /{{ path }}?{{ queryParams }}
  ///
  /// - Parameters:
  ///   - casePath: The case path used for the route.
  ///   - pathComponents: The path components used in the route.
  public static func fetch<Param>(
    _ casePath: CasePath<A, Param>,
    path pathComponents: NonEmptyArray<String>
  ) -> Router
  where Param: Codable {
    .case(casePath)
      <¢> get  // httpMethod
      %> parsePath(pathComponents)
      %> queryParams(Param.self)
      <% end
  }

  /// Create a router that matches on  GET /{{ path }}/:id
  ///
  /// - Parameters:
  ///   - casePath: The case path used for the route.
  ///   - pathComponents: The path components used in the route.
  ///   - idIso: The partial isomorphisim used to parse the `ID`.
  public static func fetchId<ID>(
    _ casePath: CasePath<A, ID>,
    path pathComponents: NonEmptyArray<String>,
    idIso: PartialIso<String, ID>
  ) -> Router {
    .case(casePath)
      <¢> get  // httpMethod
      %> parsePath(pathComponents)
      %> pathParam(idIso)
      <% end
  }

  /// Create a router that matches on POST /{{ path }}
  ///
  /// - Parameters:
  ///   - casePath: The case path used for the route.
  ///   - pathComponents: The path components used in the route.
  ///   - decoder: The json decoder used by the router.
  ///   - encoder: The json encoder used by the router.
  public static func insert<Insert>(
    _ casePath: CasePath<A, Insert>,
    path pathComponents: NonEmptyArray<String>,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) -> Router
  where Insert: Codable {
    .case(casePath)
      <¢> post  // httpMethod
      %> parsePath(pathComponents)
      %> jsonBody(Insert.self, encoder: encoder, decoder: decoder)  // body
      <% end
  }

  /// Create a router that matches on POST /{{ path }}/:id
  ///
  /// - Parameters:
  ///   - casePath: The case path used for the route.
  ///   - pathComponents: The path components used in the route.
  ///   - idIso: The partial isomorphisim used to parse the `ID`.
  ///   - decoder: The json decoder used by the router.
  ///   - encoder: The json encoder used by the router.
  public static func update<ID, Update>(
    _ casePath: CasePath<A, (ID, Update)>,
    path pathComponents: NonEmptyArray<String>,
    idIso: PartialIso<String, ID>,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) -> Router
  where Update: Codable {
    .case(casePath)
      <¢> post  // httpMethod
      %> parsePath(pathComponents)
      %> pathParam(idIso)
      <%> jsonBody(Update.self, encoder: encoder, decoder: decoder)  // body
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
