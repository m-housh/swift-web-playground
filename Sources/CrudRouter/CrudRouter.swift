import ApplicativeRouter
import CasePaths
import Foundation
import Prelude

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum CRUDRouteType: CaseIterable, Equatable {
  case fetch, fetchOne, insert, update, delete

  static let requiresId: [Self] = [.fetchOne, .update, .delete]
}

public struct CrudRouter<Model, Insert, Update>
where Model: Identifiable, Insert: Codable, Update: Codable
{
  
  public var delete: Router<Route>
  public var fetch: Router<Route>
  public var fetchOne: Router<Route>
  public var insert: Router<Route>
  public var update: Router<Route>
  
  public init(
    delete: Router<Route> = .empty,
    fetch: Router<Route> = .empty,
    fetchOne: Router<Route> = .empty,
    insert: Router<Route> = .empty,
    update: Router<Route> = .empty
  ) {
    self.delete = delete
    self.fetch = fetch
    self.fetchOne = fetchOne
    self.insert = insert
    self.update = update
  }
  
  public enum Route {
    case delete(id: Model.ID)
    case fetch
    case fetchOne(id: Model.ID)
    case insert(Insert)
    case update(id: Model.ID, update: Update)
  }
  
  func _router(_ routeType: CRUDRouteType) -> Router<Route> {
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
  
  public func router(for routes: [CRUDRouteType] = .all) -> Router<Route> {
    routes.map(_router)
      .reduce(.empty, <|>)
  }
}

extension CrudRouter.Route: Equatable
where Model.ID: Equatable, Model.ID: Equatable, Insert: Equatable, Update: Equatable { }

extension CrudRouter {
  
  public static func `default`(
    path: [String],
    idIso: PartialIso<String, Model.ID>,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) -> Self {
    
    // TODO: Use pointfreeco/NonEmpty ?
    assert(path.count > 0, "No path components found")
    let firstPathComponent = path.first!
    let rest = path.suffix(from: 1)
      
    return CrudRouter(
      delete: .case(/Route.delete)
          <¢> ApplicativeRouter.delete  // httpMethod
          %> parsePath(firstPathComponent, rest: rest)
          %> pathParam(idIso)  // route path
          <% end,
      
      fetch: .case(/Route.fetch)
        <¢> get  // httpMethod
        %> parsePath(firstPathComponent, rest: rest)
        <% end,
      
      fetchOne: .case(/Route.fetchOne)
        <¢> get  // httpMethod
        %> parsePath(firstPathComponent, rest: rest)
        %> pathParam(idIso)
        <% end,
      
      insert: .case(/Route.insert)
        <¢> post  // httpMethod
        %> parsePath(firstPathComponent, rest: rest)
        %> jsonBody(Insert.self, encoder: encoder, decoder: decoder)  // body
        <% end,
      
      update: .case(/Route.update)
        <¢> post  // httpMethod
        %> parsePath(firstPathComponent, rest: rest)
        %> pathParam(idIso)  // route path
        <%> jsonBody(Update.self, encoder: encoder, decoder: decoder)  // body
        <% end)
  }
}

extension CrudRouter where Model.ID == UUID {
  public static func `default`(
    path: [String],
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) -> Self {
    .default(path: path, idIso: .uuid, decoder: decoder, encoder: encoder)
  }
}

private func sanitizePath(_ path: String) -> String {
  if path.starts(with: "/") {
    return String(path.dropFirst())
  }
  return path
}

public func parsePath(_ first: String, rest: ArraySlice<String>) -> Router<Void> {
  rest.reduce(lit(first), { $0 %> lit($1) })
}

extension Array where Element == CRUDRouteType {
  public static var all: Self { CRUDRouteType.allCases }
}
