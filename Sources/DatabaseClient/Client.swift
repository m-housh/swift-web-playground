import Either
import Foundation
import SharedModels

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Represents the database interactions.
public struct DatabaseClient {

  public var deleteFavorite: (UserFavorite.ID) -> EitherIO<Error, Void>
  public var deleteUser: (User.ID) -> EitherIO<Error, Void>
  public var fetchFavorites: (User.ID?) -> EitherIO<Error, [UserFavorite]>
  public var fetchUsers: () -> EitherIO<Error, [User]>
  public var fetchFavorite: (UserFavorite.ID) -> EitherIO<Error, UserFavorite>
  public var fetchUser: (User.ID) -> EitherIO<Error, User>
  public var insertFavorite: (InsertFavoriteRequest) -> EitherIO<Error, UserFavorite>
  public var insertUser: (InsertUserRequest) -> EitherIO<Error, User>
  public var migrate: () -> EitherIO<Error, Void>
  public var shutdown: () -> EitherIO<Error, Void>
  public var updateFavorite: (UpdateFavoriteRequest) -> EitherIO<Error, UserFavorite>
  public var updateUser: (UpdateUserRequest) -> EitherIO<Error, User>

  public init(
    deleteFavorite: @escaping (UserFavorite.ID) -> EitherIO<Error, Void>,
    deleteUser: @escaping (User.ID) -> EitherIO<Error, Void>,
    fetchFavorites: @escaping (User.ID?) -> EitherIO<Error, [UserFavorite]>,
    fetchUsers: @escaping () -> EitherIO<Error, [User]>,
    fetchFavorite: @escaping (UserFavorite.ID) -> EitherIO<Error, UserFavorite>,
    insertFavorite: @escaping (InsertFavoriteRequest) -> EitherIO<Error, UserFavorite>,
    fetchUser: @escaping (User.ID) -> EitherIO<Error, User>,
    insertUser: @escaping (InsertUserRequest) -> EitherIO<Error, User>,
    migrate: @escaping () -> EitherIO<Error, Void>,
    shutdown: @escaping () -> EitherIO<Error, Void>,
    updateFavorite: @escaping (UpdateFavoriteRequest) -> EitherIO<Error, UserFavorite>,
    updateUser: @escaping (UpdateUserRequest) -> EitherIO<Error, User>
  ) {
    self.deleteFavorite = deleteFavorite
    self.deleteUser = deleteUser
    self.fetchFavorites = fetchFavorites
    self.fetchUsers = fetchUsers
    self.fetchFavorite = fetchFavorite
    self.fetchUser = fetchUser
    self.insertFavorite = insertFavorite
    self.insertUser = insertUser
    self.migrate = migrate
    self.shutdown = shutdown
    self.updateFavorite = updateFavorite
    self.updateUser = updateUser
  }

  public struct InsertFavoriteRequest: Codable, Equatable {
    public let userId: User.ID
    public let description: String

    public init(userId: User.ID, description: String) {
      self.userId = userId
      self.description = description
    }
  }

  public struct InsertUserRequest: Codable, Equatable {
    public let name: String

    public init(name: String) {
      self.name = name
    }
  }

  public struct UpdateFavoriteRequest: Codable, Equatable, Identifiable {
    public let id: UserFavorite.ID
    public let description: String?

    public init(id: UserFavorite.ID, description: String?) {
      self.id = id
      self.description = description
    }
  }

  public struct UpdateUserRequest: Codable, Equatable, Identifiable {
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
