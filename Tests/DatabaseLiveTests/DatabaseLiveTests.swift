import XCTest

@testable import DatabaseClient
@testable import DatabaseClientLive
@testable import SharedModels

class DatabaseLiveTests: DatabaseTestCase {

  func testInsertingUser() throws {
    let createdUser = try self.database
      .users.insert(.init(name: "blob"))
      .run.perform().unwrap()

    XCTAssertEqual(createdUser.name, "blob")
  }

  func testInsertingFavorite() throws {
    let createdUser = try self.database
      .users.insert(.init(name: "blob"))
      .run.perform().unwrap()

    let createdFavorite = try self.database
      .favorites.insert(.init(userId: createdUser.id, description: "foo"))
      .run.perform().unwrap()

    XCTAssertEqual(createdFavorite.userId, createdUser.id)
    XCTAssertEqual(createdFavorite.description, "foo")
  }

  func testFetchingUser() throws {
    let createdUser = try self.database
      .users.insert(.init(name: "blob"))
      .run.perform().unwrap()

    let fetchedAll = try self.database
      .users.fetch()
      .run.perform().unwrap()

    XCTAssertEqual(fetchedAll, [createdUser])

    let fetchedOne = try self.database
      .users.fetchId(createdUser.id)
      .run.perform().unwrap()
    XCTAssertEqual(fetchedOne, createdUser)
  }

  func testFetchingFavorite() throws {
    let createdUser = try self.database
      .users.insert(.init(name: "blob"))
      .run.perform().unwrap()

    let createdUser2 = try self.database
      .users.insert(.init(name: "blob-jr"))
      .run.perform().unwrap()

    let createdFavorite = try self.database
      .favorites.insert(.init(userId: createdUser.id, description: "foo"))
      .run.perform().unwrap()

    let createdFavorite2 = try self.database
      .favorites.insert(.init(userId: createdUser2.id, description: "bar"))
      .run.perform().unwrap()

    let fetchedAll = try self.database
      .favorites.fetch(nil)
      .run.perform().unwrap()

    XCTAssert(fetchedAll.contains(createdFavorite))
    XCTAssert(fetchedAll.contains(createdFavorite2))

    let fetchedForOne = try self.database
      .favorites.fetch(createdUser.id)
      .run.perform().unwrap()

    XCTAssertEqual(fetchedForOne, [createdFavorite])

    let fetchedOne = try self.database
      .favorites.fetchId(createdFavorite2.id)
      .run.perform().unwrap()

    XCTAssertEqual(fetchedOne, createdFavorite2)
  }

  func testUpdatingUser() throws {
    let createdUser = try self.database
      .users.insert(.init(name: "blob"))
      .run.perform().unwrap()

    let update = DatabaseClient.UserClient.UpdateRequest(id: createdUser.id, name: "updated")

    let updatedUser = try self.database
      .users.update(update)
      .run.perform().unwrap()

    XCTAssertEqual(updatedUser.id, createdUser.id)
    XCTAssertEqual(updatedUser.name, "updated")
  }

  func testUpdatingFavorite() throws {
    let createdUser = try self.database
      .users.insert(.init(name: "blob"))
      .run.perform().unwrap()

    let createdFavorite = try self.database
      .favorites.insert(.init(userId: createdUser.id, description: "foo"))
      .run.perform().unwrap()

    let update = DatabaseClient.UserFavoriteClient.UpdateRequest(
      id: createdFavorite.id, description: "not foo"
    )

    let updatedFavorite = try self.database
      .favorites.update(update)
      .run.perform().unwrap()

    XCTAssertEqual(updatedFavorite.id, createdFavorite.id)
    XCTAssertEqual(updatedFavorite.description, "not foo")
  }

  func testDeletingUser() throws {
    let createdUser = try self.database
      .users.insert(.init(name: "blob"))
      .run.perform().unwrap()

    let fetched = try self.database
      .users.fetch()
      .run.perform().unwrap()

    XCTAssertEqual(fetched.count, 1)

    try self.database
      .users.delete(createdUser.id)
      .run.perform().unwrap()

    let fetched2 = try self.database
      .users.fetch()
      .run.perform().unwrap()
    XCTAssertEqual(fetched2.count, 0)
  }

  func testDeletingFavorite() throws {
    let createdUser = try self.database
      .users.insert(.init(name: "blob"))
      .run.perform().unwrap()

    let createdFavorite = try self.database
      .favorites.insert(.init(userId: createdUser.id, description: "foo"))
      .run.perform().unwrap()

    let fetched = try self.database
      .favorites.fetch(nil)
      .run.perform().unwrap()

    XCTAssertEqual(fetched.count, 1)

    try self.database
      .favorites.delete(createdFavorite.id)
      .run.perform().unwrap()

    let fetched2 = try self.database
      .favorites.fetch(nil)
      .run.perform().unwrap()
    XCTAssertEqual(fetched2.count, 0)
  }
}
