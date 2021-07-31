#if DEBUG
  import Either
  import XCTestDynamicOverlay

  extension EitherIO where E == Error {

    public static func failing(_ message: String) -> Self {
      .init(
        run: .init {
          XCTFail(message)
          return .left(FailingError(message: message))
        })
    }

    public struct FailingError: Error {
      let message: String
    }
  }

  extension EitherIO {
    public init(value: A) {
      self.init(
        run: .init {
          .right(value)
        })
    }
  }
#endif
