import ApplicativeRouter
import Foundation
import SharedModels

public struct InsertUser: Codable, Equatable {
  public let name: String
}

public typealias UserRoute = CRUDRoute<User, InsertUser, User>
public typealias UserRouter = Router<UserRoute>

extension UserRouter {
  
  public init(
    _ path: String,
    encoder jsonEncoder: JSONEncoder = .init(),
    decoder jsonDecoder: JSONDecoder = .init()
  ) {
    self = crudRouter(path, id: .uuid, encoder: jsonEncoder, decoder: jsonDecoder)
  }
}
