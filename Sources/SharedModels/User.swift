import Foundation

public struct User: Codable, Identifiable, Equatable {
  public var id: UUID
  public var name: String
  
  init(id: UUID, name: String) {
    self.id = id
    self.name = name
  }
}
