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
  
  func testUpdatingUser() throws {
    let createdUser = try self.database.insertUser(.init(name: "blob"))
      .run.perform().unwrap()
    
    let update = DatabaseClient.UpdateUserRequest(id: createdUser.id, name: "updated")
    
    let updatedUser = try self.database.updateUser(update)
      .run.perform().unwrap()
    
    XCTAssertEqual(updatedUser.id, createdUser.id)
    XCTAssertEqual(updatedUser.name, "updated")
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
}
