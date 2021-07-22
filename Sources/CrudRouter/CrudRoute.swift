import ApplicativeRouter
import CasePaths
import Foundation
import NonEmpty
import Prelude

/// A namespace for creating routers that can handle CRUD operations.
public enum CrudRoute {

  /// Create a router that matches on  DELETE /{{ path }}/:id
  ///
  /// - Parameters:
  ///   - casePath: The case path used for the route.
  ///   - pathComponents: The path components used in the route.
  ///   - idIso: The partial isomorphisim used to parse the `ID`.
  public static func delete<Route, ID>(
    _ casePath: CasePath<Route, ID>,
    path pathComponents: NonEmptyArray<String>,
    idIso: PartialIso<String, ID>
  ) -> Router<Route> {
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
  public static func fetch<Route>(
    _ casePath: CasePath<Route, Void>,
    path pathComponents: NonEmptyArray<String>
  ) -> Router<Route> {
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
  public static func fetch<Route, Param>(
    _ casePath: CasePath<Route, Param>,
    path pathComponents: NonEmptyArray<String>,
    param: (key: String, iso: PartialIso<String?, Param>)
  ) -> Router<Route> {
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
  public static func fetch<Route, Param>(
    _ casePath: CasePath<Route, Param>,
    path pathComponents: NonEmptyArray<String>
  ) -> Router<Route> where Param: Codable {
    .case(casePath)
      <¢> get  // httpMethod
      %> parsePath(pathComponents)
      %> queryParams(Param.self)
      <% end
  }

  /// Create a router that matches on two query parameter
  ///
  /// GET /{{ path }}?{{ aParam.key }}=:aParam.iso&{{ bParam.key }}=:bParam.iso
  ///
  /// - Parameters:
  ///   - casePath: The case path used for the route.
  ///   - pathComponents: The path components used in the route.
  ///   - aParam: The key and partial isomorphisim used to parse the first query parameter.
  ///   - bParam: The key and partial isomorphisim used to parse the second query parameter.
  public static func fetch<Route, A, B>(
    _ casePath: CasePath<Route, (A, B)>,
    path pathComponents: NonEmptyArray<String>,
    param aParam: (key: String, iso: PartialIso<String?, A>),
    param bParam: (key: String, iso: PartialIso<String?, B>)
  ) -> Router<Route> {
    .case(casePath)
      <¢> get  // httpMethod
      %> parsePath(pathComponents)
      %> queryParam(aParam.key, aParam.iso)
      <%> queryParam(bParam.key, bParam.iso)
      <% end
  }

  /// Create a router that matches on  GET /{{ path }}/:id
  ///
  /// - Parameters:
  ///   - casePath: The case path used for the route.
  ///   - pathComponents: The path components used in the route.
  ///   - idIso: The partial isomorphisim used to parse the `ID`.
  public static func fetchId<Route, ID>(
    _ casePath: CasePath<Route, ID>,
    path pathComponents: NonEmptyArray<String>,
    idIso: PartialIso<String, ID>
  ) -> Router<Route> {
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
  public static func insert<Route, Insert>(
    _ casePath: CasePath<Route, Insert>,
    path pathComponents: NonEmptyArray<String>,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) -> Router<Route> where Insert: Codable {
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
  public static func update<Route, ID, Update>(
    _ casePath: CasePath<Route, (ID, Update)>,
    path pathComponents: NonEmptyArray<String>,
    idIso: PartialIso<String, ID>,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) -> Router<Route> where Update: Codable {
    .case(casePath)
      <¢> post  // httpMethod
      %> parsePath(pathComponents)
      %> pathParam(idIso)
      <%> jsonBody(Update.self, encoder: encoder, decoder: decoder)  // body
      <% end
  }
}
