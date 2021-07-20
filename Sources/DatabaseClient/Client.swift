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
  public var shutdown: () -> EitherIO<Error, Void>
  public var updateUser: (UpdateUserRequest) -> EitherIO<Error, User>
  
  public init(
    deleteUser: @escaping (User.ID) -> EitherIO<Error, Void>,
    fetchUsers: @escaping () -> EitherIO<Error, [User]>,
    fetchUser: @escaping (User.ID) -> EitherIO<Error, User>,
    insertUser: @escaping (InsertUserRequest) -> EitherIO<Error, User>,
    migrate: @escaping () -> EitherIO<Error, Void>,
    shutdown: @escaping () -> EitherIO<Error, Void>,
    updateUser: @escaping (UpdateUserRequest) -> EitherIO<Error, User>
  ) {
    self.fetchUsers = fetchUsers
    self.fetchUser = fetchUser
    self.insertUser = insertUser
    self.migrate = migrate
    self.shutdown = shutdown
    self.updateUser = updateUser
    self.deleteUser = deleteUser
  }
  
  public struct UpdateUserRequest: Codable {
    public let id: User.ID
    public let name: String?
    
    public init(
      id: User.ID,
      name: String?
    ) {
      self.id = id
      self.name = name
    }
  }
}
