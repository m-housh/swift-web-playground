import Either
import Foundation
import SharedModels

#if canImport(FoundationNetworking)
  import FoundationNetworking
import XCTest
#endif

/// Represents all the database interactions for the application.
public struct DatabaseClient {

  /// Actions that can be taken on the users table.
  public var users: UserClient

  /// Actions that can be taken on the favorites table.
  public var favorites: UserFavoriteClient

  /// Perform migrations on the database.
  public var migrate: () -> EitherIO<Error, Void>

  /// Shutdown the database connection.
  public var shutdown: () -> EitherIO<Error, Void>

  /// Create a new database client.
  ///
  /// - Parameters:
  ///   - users: The user client to use.
  ///   - favorites: The user favorites client to use.
  ///   - migrate: Perform migrations on the database.
  ///   - shutdown: Shutdown the database connection.
  public init(
    users: UserClient,
    favorites: UserFavoriteClient,
    migrate: @escaping () -> EitherIO<Error, Void>,
    shutdown: @escaping () -> EitherIO<Error, Void>
  ) {
    self.users = users
    self.favorites = favorites
    self.migrate = migrate
    self.shutdown = shutdown
  }
}

// MARK: - Users
extension DatabaseClient {

  /// Represents actions that can be taken on the users table in the database.
  public struct UserClient {

    /// Delete a user from the database.
    public var delete: (User.ID) -> EitherIO<Error, Void>

    /// Fetch all users from the database.
    public var fetch: () -> EitherIO<Error, [User]>

    /// Fetch a user by id from the database.
    public var fetchId: (User.ID) -> EitherIO<Error, User>

    /// Insert a new user to the database.
    public var insert: (InsertRequest) -> EitherIO<Error, User>

    /// Update a user in the database.
    public var update: (UpdateRequest) -> EitherIO<Error, User>

    /// Create a new user database client.
    ///
    /// - Parameters:
    ///   - delete: Function that deletes a user from the database.
    ///   - fetch: Function that fetches all users from the database.
    ///   - fetchId: Function that fetches a user by id from the database.
    ///   - insert: Function that inserts a new user to the database.
    ///   - update: Function that updates a user in the database.
    public init(
      delete: @escaping (User.ID) -> EitherIO<Error, Void>,
      fetch: @escaping () -> EitherIO<Error, [User]>,
      fetchId: @escaping (User.ID) -> EitherIO<Error, User>,
      insert: @escaping (InsertRequest) -> EitherIO<Error, User>,
      update: @escaping (UpdateRequest) -> EitherIO<Error, User>
    ) {
      self.delete = delete
      self.fetch = fetch
      self.fetchId = fetchId
      self.insert = insert
      self.update = update
    }

    /// Represents the data needed to insert a new user to the database.
    public struct InsertRequest: Codable, Equatable {

      /// The user's name.
      public let name: String

      /// Create a new insert user request.
      ///
      /// - Parameters:
      ///   - name: The user's name.
      public init(name: String) {
        self.name = name
      }
    }

    /// Represents the data needed to update a user in the database.
    public struct UpdateRequest: Codable, Equatable, Identifiable {

      /// The user's unique identifier in the database.
      public let id: User.ID

      /// The user's updated name.
      public let name: String?

      /// Create a new update user request.
      ///
      /// - Parameters:
      ///    - id: The user's unique identifier in the database.
      ///    - name: The user's updated name.
      public init(
        id: User.ID,
        name: String?
      ) {
        self.id = id
        self.name = name
      }
    }
  }
}

// MARK: - UserFavorites
extension DatabaseClient {

  /// Represents the actions that can be taken on the user favorites table.
  public struct UserFavoriteClient {

    /// Delete a user favorite from the database.
    public var delete: (UserFavorite.ID) -> EitherIO<Error, Void>

    /// Fetch all user favorites or all user favorites for the given user id from the database.
    public var fetch: (User.ID?) -> EitherIO<Error, [UserFavorite]>

    /// Fetch a user favorite  by id from the database.
    public var fetchId: (UserFavorite.ID) -> EitherIO<Error, UserFavorite>

    /// Insert a new user favorite to the database.
    public var insert: (InsertRequest) -> EitherIO<Error, UserFavorite>

    /// Update a user favorite in the database.
    public var update: (UpdateRequest) -> EitherIO<Error, UserFavorite>

    /// Create a new user favorite database client.
    ///
    /// - Parameters:
    ///   - delete: Function that deletes a user favorite from the database.
    ///   - fetch: Function that fetchesall user favorites or all user favorites for the given user id from the database.
    ///   - fetchId: Function that fetches a user favorite by id from the database.
    ///   - insert: Function that inserts a new user favorite to the database.
    ///   - update: Function that updates a user favorite in the database.
    public init(
      delete: @escaping (UserFavorite.ID) -> EitherIO<Error, Void>,
      fetch: @escaping (User.ID?) -> EitherIO<Error, [UserFavorite]>,
      fetchId: @escaping (UserFavorite.ID) -> EitherIO<Error, UserFavorite>,
      insert: @escaping (InsertRequest) -> EitherIO<Error, UserFavorite>,
      update: @escaping (UpdateRequest) -> EitherIO<Error, UserFavorite>
    ) {
      self.delete = delete
      self.fetch = fetch
      self.fetchId = fetchId
      self.insert = insert
      self.update = update
    }

    /// Represents the data required to insert a new user favorite to the database.
    public struct InsertRequest: Codable, Equatable {

      /// The user's identifier that the favorite belongs to.
      public let userId: User.ID

      /// The description of the user favorite.
      public let description: String

      /// Create a new insert request.
      ///
      /// - Parameters:
      ///   - userId: The user's identifier that the favorite belongs to.
      ///   - description: The description of the user favorite.
      public init(userId: User.ID, description: String) {
        self.userId = userId
        self.description = description
      }
    }

    /// Represents the data required to update a user favorite in the database.
    public struct UpdateRequest: Codable, Equatable, Identifiable {

      /// The unique identifier of the user favorite in the database.
      public let id: UserFavorite.ID

      /// The updated description of the user favorite.
      public let description: String?

      /// Create a new update favorites request.
      ///
      /// - Parameters:
      ///   - id: The unique identifier of the user favorite in the database.
      ///   - description: The updated description of the user favorite.
      public init(id: UserFavorite.ID, description: String?) {
        self.id = id
        self.description = description
      }
    }
  }
}

#if DEBUG
import ServerTestHelpers
import XCTestDynamicOverlay

extension DatabaseClient {

  public static let failing = DatabaseClient(
    users: .init(
      delete: {_ in
        .failing("\(Self.self).delete is unimplemented.")
      },
      fetch: {
        .failing("\(Self.self).fetch is unimplemented.")
      },
      fetchId: { _ in
        .failing("\(Self.self).fetchId is unimplemented.")
      },
      insert: { _ in
        .failing("\(Self.self).insert is unimplemented.")
      },
      update: { _ in
        .failing("\(Self.self).update is unimplemented.")
      }),
    favorites: .init(
      delete: {_ in
        .failing("\(Self.self).delete is unimplemented.")
      },
      fetch: { _ in
        .failing("\(Self.self).fetch is unimplemented.")
      },
      fetchId: { _ in
        .failing("\(Self.self).fetchId is unimplemented.")
      },
      insert: { _ in
        .failing("\(Self.self).insert is unimplemented.")
      },
      update: { _ in
        .failing("\(Self.self).update is unimplemented.")
      }),
    migrate: { .failing("\(Self.self).migrate is unimplemented.") },
    shutdown: { .failing("\(Self.self).shutdown is unimplemented.") })
}

#endif
