//
//  Float2Exts.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/17/26.
//

import simd
import RealModule

public typealias Float2 = SIMD2<Float>
public typealias F2 = Float2

public extension Float2 {
  var length: Float {
    (x * x + y * y).squareRoot()
  }
}

extension Float2 where Scalar: Real {
  /// Test if self and other are approximately equal with specified tolerances.
  func isApproximatelyEqual(
    to other: Self,
    absoluteTolerance: Scalar = 0.0,
    relativeTolerance: Scalar = Scalar.ulpOfOne.squareRoot()
  ) -> Bool {
    return self.x.isApproximatelyEqual(to: other.x, absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance) &&
    self.y.isApproximatelyEqual(to: other.y, absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance)
  }

  /// Test if self and other are close enough with specified tolerances.
  public func isClose(
    to other: Self,
    absoluteTolerance: Scalar = 0.0,
    relativeTolerance: Scalar = Scalar.ulpOfOne.squareRoot()
  ) -> Bool {
    return isApproximatelyEqual(
      to: other,
      absoluteTolerance: absoluteTolerance,
      relativeTolerance: relativeTolerance
    )
  }
}
