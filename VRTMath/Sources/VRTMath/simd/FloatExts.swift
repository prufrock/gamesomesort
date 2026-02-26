//
//  FloatExts.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/25/26.
//

import simd
import RealModule

extension Float {
  /// Test if self and other are close enough with specified tolerances.
  public func isClose(
    to other: Self,
    absoluteTolerance: Float = 0.0,
    relativeTolerance: Float = Float.ulpOfOne.squareRoot()
  ) -> Bool {
    return isApproximatelyEqual(
      to: other,
      absoluteTolerance: absoluteTolerance,
      relativeTolerance: relativeTolerance
    )
  }
}
