import XCTest

@testable import DatabaseClient
@testable import DatabaseClientLive
@testable import SharedModels

class DatabaseLiveTests: DatabaseTestCase {
  
  func testInsertingUser() throws {
    let createdUser = try self.database.insertUser(.init(name: "blob"))
      .run.perform().unwrap()
    
    XCTAssertEqual(createdUser.name, "blob")
  }
  
  func testInsertingFavorite() throws {
    let createdUser = try self.database.insertUser(.init(name: "blob"))
      .run.perform().unwrap()
    
    let createdFavorite = try self.database.insertFavorite(.init(userId: createdUser.id, description: "foo"))
      .run.perform().unwrap()
    
    XCTAssertEqual(createdFavorite.userId, createdUser.id)
    XCTAssertEqual(createdFavorite.description, "foo")
  }
  
  func testFetchingUser() throws {
    let createdUser = try self.database.insertUser(.init(name: "blob"))
      .run.perform().unwrap()
    
    let fetchedAll = try self.database.fetchUsers()
      .run.perform().unwrap()
    
    XCTAssertEqual(fetchedAll, [createdUser])
    
    let fetchedOne = try self.database.fetchUser(createdUser.id)
      .run.perform().unwrap()
    XCTAssertEqual(fetchedOne, createdUser)
  }
  
  func testFetchingFavorite() throws {
    let createdUser = try self.database.insertUser(.init(name: "blob"))
      .run.perform().unwrap()
    
    let createdUser2 = try self.database.insertUser(.init(name: "blob-jr"))
      .run.perform().unwrap()
        
    let createdFavorite = try self.database.insertFavorite(.init(userId: createdUser.id, description: "foo"))
      .run.perform().unwrap()
    
    let createdFavorite2 = try self.database.insertFavorite(.init(userId: createdUser2.id, description: "bar"))
      .run.perform().unwrap()
    
    let fetchedAll = try self.database.fetchFavorites(nil)
      .run.perform().unwrap()
    
    XCTAssert(fetchedAll.contains(createdFavorite))
    XCTAssert(fetchedAll.contains(createdFavorite2))

    let fetchedForOne = try self.database.fetchFavorites(createdUser.id)
      .run.perform().unwrap()
    
    XCTAssertEqual(fetchedForOne, [createdFavorite])
    
    let fetchedOne = try self.database.fetchFavorite(createdFavorite2.id)
      .run.perform().unwrap()
    
    XCTAssertEqual(fetchedOne, createdFavorite2)
  }
  
  func testUpdatingUser() throws {
    let createdUser = try self.database.insertUser(.init(name: "blob"))
      .run.perform().unwrap()
    
    let update = DatabaseClient.UpdateUserRequest(id: createdUser.id, name: "updated")
    
    let updatedUser = try self.database.updateUser(update)
      .run.perform().unwrap()
    
    XCTAssertEqual(updatedUser.id, createdUser.id)
    XCTAssertEqual(updatedUser.name, "updated")
  }
  
  
  func testUpdatingFavorite() throws {
    let createdUser = try self.database.insertUser(.init(name: "blob"))
      .run.perform().unwrap()
    
    
    let createdFavorite = try self.database.insertFavorite(.init(userId: createdUser.id, description: "foo"))
      .run.perform().unwrap()
    
    let update = DatabaseClient.UpdateFavoriteRequest(id: createdFavorite.id, description: "not foo")
    
    let updatedFavorite = try self.database.updateFavorite(update)
      .run.perform().unwrap()
    
    XCTAssertEqual(updatedFavorite.id, createdFavorite.id)
    XCTAssertEqual(updatedFavorite.description, "not foo")
  }
  
  func testDeletingUser() throws {
    let createdUser = try self.database.insertUser(.init(name: "blob"))
      .run.perform().unwrap()
    
    let fetched = try self.database.fetchUsers()
      .run.perform().unwrap()
    
    XCTAssertEqual(fetched.count, 1)
    
    try self.database.deleteUser(createdUser.id)
      .run.perform().unwrap()
    
    let fetched2 = try self.database.fetchUsers()
      .run.perform().unwrap()
    XCTAssertEqual(fetched2.count, 0)
  }
  
  func testDeletingFavorite() throws {
    let createdUser = try self.database.insertUser(.init(name: "blob"))
      .run.perform().unwrap()
    
    
    let createdFavorite = try self.database.insertFavorite(.init(userId: createdUser.id, description: "foo"))
      .run.perform().unwrap()
    
    let fetched = try self.database.fetchFavorites(nil)
      .run.perform().unwrap()
    
    XCTAssertEqual(fetched.count, 1)
    
    try self.database.deleteFavorite(createdFavorite.id)
      .run.perform().unwrap()
    
    let fetched2 = try self.database.fetchFavorites(nil)
      .run.perform().unwrap()
    XCTAssertEqual(fetched2.count, 0)
  }
}
