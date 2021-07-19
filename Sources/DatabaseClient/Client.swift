import Either
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
import SharedModels

/// Represents the database interactions.
public struct DatabaseClient {
  
  public var deleteUser: (User.ID) -> EitherIO<Error, Void>
  public var fetchUsers: () -> EitherIO<Error, [User]>
  public var fetchUser: (User.ID) -> EitherIO<Error, User>
  public var insertUser: (InsertUserRequest) -> EitherIO<Error, User>
  public var migrate: () -> EitherIO<Error, Void>
  public var updateUser: (User) -> EitherIO<Error, User>
  
  public init(
    deleteUser: @escaping (User.ID) -> EitherIO<Error, Void>,
    fetchUsers: @escaping () -> EitherIO<Error, [User]>,
    fetchUser: @escaping (User.ID) -> EitherIO<Error, User>,
    insertUser: @escaping (InsertUserRequest) -> EitherIO<Error, User>,
    migrate: @escaping () -> EitherIO<Error, Void>,
    updateUser: @escaping (User) -> EitherIO<Error, User>
  ) {
    self.fetchUsers = fetchUsers
    self.fetchUser = fetchUser
    self.insertUser = insertUser
    self.migrate = migrate
    self.updateUser = updateUser
    self.deleteUser = deleteUser
  }
}

extension DatabaseClient {
  
  public struct InsertUserRequest {
    public let name: String
    public init(name: String) {
      self.name = name
    }
  }
}
