import struct Foundation.UUID

/// Represents the api routes that we will serve in the application.
///
///
public enum ApiRoute: Equatable {

  /// The `/users` routes.
  case users(UsersRoute)

  /// The `/favorites` routes.
  case favorites(FavoritesRoute)

  /// Represents the `/users` CRUD routes.
  public enum UsersRoute: Equatable {
    case delete(id: User.ID)
    case fetch
    case fetchId(id: User.ID)
    case insert(InsertRequest)
    case update(id: User.ID, update: UpdateRequest)

    /// Represents the required properties to insert a new `User`.
    public struct InsertRequest: Equatable, Codable {
      public let name: String

      public init(name: String) {
        self.name = name
      }
    }

    // TODO: Make name non-optional
    /// Represents the required properties to update a `User`.
    public struct UpdateRequest: Equatable, Codable {
      public let name: String?

      public init(name: String?) {
        self.name = name
      }
    }
  }

  /// Represents the `/favorites` CRUD routes.
  public enum FavoritesRoute: Equatable {

    case delete(id: UserFavorite.ID)
    case fetch(userId: User.ID?)
    case fetchId(id: UserFavorite.ID)
    case insert(InsertRequest)
    case update(id: UserFavorite.ID, update: UpdateRequest)

    /// Represents the required properties to insert a new `UserFavorite`.
    public struct InsertRequest: Equatable, Codable {

      public let description: String
      public let userId: User.ID

      public init(description: String, userId: User.ID) {
        self.description = description
        self.userId = userId
      }
    }

    // TODO: Make description non-optional
    /// Represents the required properties to update a `UserFavorite`.
    public struct UpdateRequest: Equatable, Codable {
      public let description: String?

      public init(description: String?) {
        self.description = description
      }
    }
  }
}
