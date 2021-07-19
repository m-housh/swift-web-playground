import ApplicativeRouter
import CasePaths
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
import Prelude

public enum CRUDRoute<Model, Update>
  where Model: Codable, Model: Identifiable, Update: Codable
{
  case fetch
  case fetchOne(id: Model.ID)
  case insert(Model)
  case update(id: Model.ID, update: Update)
  case delete(id: Model.ID)
}

extension CRUDRoute: Equatable where Model: Equatable, Model.ID: Equatable, Update: Equatable { }

public enum CRUDRouteType: CaseIterable, Equatable {
  case fetch, fetchOne, insert, update, delete
    
  static let requiresId: [Self] = [.fetchOne, .update, .delete]
  
  public func router<M, U>(
    path: String,
    id idIso: PartialIso<String, M.ID>?,
    encoder jsonEncoder: JSONEncoder,
    decoder jsonDecoder: JSONDecoder
  ) -> Router<CRUDRoute<M, U>>
    where M: Codable, M: Identifiable, U: Codable
  {
    if idIso == nil {
      assert(!Self.requiresId.contains(self), "A partial iso is required for the `id` routes.")
    }
    
    switch self {
    case .fetch:
      // matches GET /{{ path }}
      return .case(/CRUDRoute<M, U>.fetch)
        <¢> get // httpMethod
        %> lit(path) // route path
        <% end
      
    case .fetchOne:
      // matches GET /{{ path }}/:id
      return .case(/CRUDRoute<M, U>.fetchOne)
        <¢> get // httpMethod
        %> lit(path) %> pathParam(idIso!) // route path
        <% end
      
    case .insert:
      // matches POST /{{ path }}
      return .case(/CRUDRoute<M, U>.insert)
          <¢> post // httpMethod
          %> lit(path) // route path
          %> jsonBody(M.self, encoder: jsonEncoder, decoder: jsonDecoder) // body
          <% end
      
    case .update:
      // matches POST /{{ path }}/:id
      return .case(/CRUDRoute<M, U>.update)
        <¢> post // httpMethod
        %> lit(path) %> pathParam(idIso!) // route path
        <%> jsonBody(U.self) // body
        <% end
      
    case .delete:
      // matches DELETE /{{ path }}/:id
      return .case(/CRUDRoute<M, U>.delete)
        <¢> ApplicativeRouter.delete // httpMethod
        %> lit(path) %> pathParam(idIso!) // route path
        <% end
    }
  }
}

// Create a router with the supplied routes.
public func crudRouter<Model, Update>(
  _ path: String,
  routes: [CRUDRouteType],
  id idIso: PartialIso<String, Model.ID>? = nil,
  encoder jsonEncoder: JSONEncoder = .init(),
  decoder jsonDecoder: JSONDecoder = .init()
) -> Router<CRUDRoute<Model, Update>>
  where Model: Codable, Model: Identifiable, Update: Codable
{
  let path = sanitizePath(path)
  return routes
    .map { $0.router(path: path, id: idIso, encoder: jsonEncoder, decoder: jsonDecoder) }
    .reduce(.empty, <|>)
  
}

/// Create a router with the supplied routes.
public func crudRouter<M, U>(
  _ path: String,
  id idIso: PartialIso<String, M.ID>? = nil,
  encoder jsonEncoder: JSONEncoder = .init(),
  decoder jsonDecoder: JSONDecoder = .init(),
  using routes: CRUDRouteType...
) -> Router<CRUDRoute<M, U>>
  where M: Codable, M: Identifiable, U: Codable
{
  crudRouter(
    path,
    routes: routes,
    id: idIso,
    encoder: jsonEncoder,
    decoder: jsonDecoder
  )
}

// Create a router using all the routes.
public func crudRouter<M, U>(
  _ path: String,
  id idIso: PartialIso<String, M.ID>,
  encoder jsonEncoder: JSONEncoder = .init(),
  decoder jsonDecoder: JSONDecoder = .init()
) -> Router<CRUDRoute<M, U>>
  where M: Codable, M: Identifiable, U: Codable
{
  crudRouter(
    path,
    routes: CRUDRouteType.allCases,
    id: idIso,
    encoder: jsonEncoder,
    decoder: jsonDecoder
  )
}

private func sanitizePath(_ path: String) -> String {
  if path.starts(with: "/") {
    return String(path.dropFirst())
  }
  return path
}
