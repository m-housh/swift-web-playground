import Foundation

public enum ApiRoute: Equatable {

  case users(UsersRoute)
  case favorites(FavoritesRoute)

  public enum UsersRoute: Equatable {
    case delete(id: User.ID)
    case fetch
    case fetchId(id: User.ID)
    case insert(InsertRequest)
    case update(id: User.ID, update: UpdateRequest)

    public struct InsertRequest: Equatable, Codable {
      public let name: String

      public init(name: String) {
        self.name = name
      }
    }

    // TODO: Make name non-optional
    public struct UpdateRequest: Equatable, Codable {
      public let name: String?

      public init(name: String?) {
        self.name = name
      }
    }
  }

  public enum FavoritesRoute: Equatable {

    case delete(id: UserFavorite.ID)
    case fetch(userId: User.ID?)
    case fetchId(id: UserFavorite.ID)
    case insert(InsertRequest)
    case update(id: UserFavorite.ID, update: UpdateRequest)

    public struct InsertRequest: Equatable, Codable {

      public let description: String
      public let userId: User.ID

      public init(description: String, userId: User.ID) {
        self.description = description
        self.userId = userId
      }
    }

    // TODO: Make description non-optional
    public struct UpdateRequest: Equatable, Codable {
      public let description: String?

      public init(description: String?) {
        self.description = description
      }
    }
  }
}
