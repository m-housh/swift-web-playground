import ApplicativeRouter
import CasePaths
import Foundation
import Prelude

extension PartialIso {
  public static func `case`(_ path: CasePath<B, A>) -> PartialIso {
    parenthesize <| PartialIso(apply: path.embed(_:), unapply: path.extract(from:))
  }
}
