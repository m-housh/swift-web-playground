import Foundation

public struct UserFavorite: Codable, Equatable, Identifiable {
  public var id: UUID
  public var userId: User.ID
  public var description: String
  
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
