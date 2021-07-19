import ApplicativeRouter
import CasePaths
import Foundation
import Prelude

extension PartialIso {
  public static func `case`(_ path: CasePath<B, A>) -> PartialIso {
    path.iso
  }
}

extension CasePath {
  var iso: PartialIso<Value, Root> {
    parenthesize <| PartialIso(
      apply: { embed($0) },
      unapply: { extract(from: $0) }
    )
  }
}
