import struct Foundation.UUID

/// A simple user that we store in the database that only has a name and an id.
public struct User: Codable, Identifiable, Equatable {

  /// The unique identifier of the user.
  public var id: UUID

  /// The user's name.
  public var name: String

  /// Create a new user.
  ///
  /// - Parameters:
  ///   - id: The unique identifier of the user.
  ///   - name: The user's name.
  public init(id: UUID, name: String) {
    self.id = id
    self.name = name
  }
}

#if DEBUG

  extension User {

    public static let blob = User(
      id: UUID(uuidString: "DEADBEEF-0001-BEEF-DEAD-BEEFDEADBEEF")!,
      name: "blob"
    )

    public static let blobJr = User(
      id: UUID(uuidString: "DEADBEEF-0002-BEEF-DEAD-BEEFDEADBEEF")!,
      name: "blob-jr"
    )

    public static let blobSr = User(
      id: UUID(uuidString: "DEADBEEF-0003-BEEF-DEAD-BEEFDEADBEEF")!,
      name: "blob-sr"
    )
  }

#endif
