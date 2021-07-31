import struct Foundation.UUID

/// A simple user favorite. This was created to have a simple `User` relation.
public struct UserFavorite: Codable, Equatable, Identifiable {

  /// The unique identifier of the favorite.
  public var id: UUID

  /// The `User.ID` that the favorite belongs to.
  public var userId: User.ID

  /// A description of the favorite.
  public var description: String

  /// Create a new favorite.
  ///
  ///  - Parameters:
  ///   - id: The unique identifier of the favorite.
  ///   - userId: The user's identifier that this favorite belongs to.
  ///   - description: A description of the favorite.
  public init(
    id: UUID,
    userId: User.ID,
    description: String
  ) {
    self.id = id
    self.userId = userId
    self.description = description
  }
}

#if DEBUG
  extension UserFavorite {

    public static func pizza(userId: User.ID) -> UserFavorite {
      UserFavorite(
        id: UUID(uuidString: "DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF")!,
        userId: userId,
        description: "pizza"
      )
    }

    public static func tacos(userId: User.ID) -> UserFavorite {
      UserFavorite(
        id: UUID(uuidString: "DEADBEEF-0002-BEEF-DEAD-BEEFDEADBEEF")!,
        userId: userId,
        description: "tacos"
      )
    }

    public static func coffee(userId: User.ID) -> UserFavorite {
      UserFavorite(
        id: UUID(uuidString: "DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF")!,
        userId: userId,
        description: "coffee"
      )
    }
  }

  extension Array where Element == UserFavorite {

    public static let blobsFavorites: Self = [
      .pizza(userId: User.blob.id),
      .coffee(userId: User.blob.id),
    ]

    public static let blobJrsFavorites: Self = [
      .tacos(userId: User.blobJr.id)
    ]

    public static let blobSrsFavorites: Self = [
      .coffee(userId: User.blobJr.id)
    ]
  }
#endif
