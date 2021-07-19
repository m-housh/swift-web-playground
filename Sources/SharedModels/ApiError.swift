import Foundation

public struct ApiError: Error {
  let error: Error
  
  init(error: Error) {
    self.error = error
  }
  
}
