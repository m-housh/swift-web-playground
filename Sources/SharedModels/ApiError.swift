import Foundation

/// Represents errors that are thrown from the api. By wrapping an error that was thrown
/// and allowing it to be codable to be sent for debugging.
public struct ApiError: Codable, Error, Equatable, LocalizedError {

  /// The wrapped error dump.
  public let errorDump: String

  /// The file it was thrown from.
  public let file: String

  /// The line it was thrown from.
  public let line: UInt

  /// The error message.
  public let message: String

  /// Create a new api error.
  ///
  /// - Parameters:
  ///  - error: The error that was thrown / we are wrapping.
  ///  - file: The file it was thrown from.
  ///  - line: The line it was thrown from.
  public init(
    error: Error,
    file: StaticString = #fileID,
    line: UInt = #line
  ) {
    var string = ""
    dump(error, to: &string)
    self.errorDump = string
    self.file = String(describing: file)
    self.line = line
    self.message = error.localizedDescription
  }

  public var errorDescription: String? {
    self.message
  }
}

#if DEBUG
  extension ApiError {

    init(
      errorDump: String,
      message: String,
      file: StaticString = #fileID,
      line: UInt = #line
    ) {
      self.errorDump = errorDump
      self.message = message
      self.file = String(describing: file)
      self.line = line
    }

    public static func testing(
      file: StaticString = #fileID,
      line: UInt = #line
    ) -> Self {
      self.init(
        errorDump: "Testing error.", message: "This is an error for testing", file: file, line: line
      )
    }
  }

#endif
