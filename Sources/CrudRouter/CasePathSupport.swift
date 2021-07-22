import ApplicativeRouter
import CasePaths
import Foundation
import Prelude

extension PartialIso {

  /// Create a new `PartialIso` with the given `CasePath`.
  ///
  /// - Parameters:
  ///   - path: The case path to use for the partial isomorphism.
  public static func `case`(_ path: CasePath<B, A>) -> PartialIso {
    parenthesize <| PartialIso(apply: path.embed(_:), unapply: path.extract(from:))
  }
}
