import Stockee
import CoreGraphics
import Foundation

extension CGFloat {
    var rounded: CGFloat {
        (self * 100).rounded() / 100
    }
}

extension BOLLIndicator {
    var rounded: BOLLIndicator {
        .init(lower: lower.rounded,
              middle: middle.rounded,
              upper: upper.rounded)
    }
}
