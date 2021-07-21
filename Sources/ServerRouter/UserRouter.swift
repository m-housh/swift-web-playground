import ApplicativeRouter
import CrudRouter
import Foundation
import SharedModels

public typealias UserRoute = CRUDRoute<User, InsertUserRequest, UpdateUserRequest>
public typealias UserRouter = Router<UserRoute>

extension UserRouter {
  
  public init(
    _ path: String...,
    encoder jsonEncoder: JSONEncoder = .init(),
    decoder jsonDecoder: JSONDecoder = .init()
  ) {
    self = crudRouter(
      path,
      id: .uuid,
      encoder: jsonEncoder,
      decoder: jsonDecoder
    )
  }
}
