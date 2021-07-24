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
