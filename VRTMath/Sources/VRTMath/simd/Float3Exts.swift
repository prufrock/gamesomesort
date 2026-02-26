//
//  Float3Exts.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/17/26.
//

import simd
import RealModule

public typealias Float3 = SIMD3<Float>
public typealias F3 = Float3

public extension Float3 {
  var xy: F2 {
    F2(x: x, y: y)
  }

  static func quaternion(_ rotation: Float3) -> simd_quatf {
    Float4x4.rotate(rotation).q
  }
}

extension Float3 where Scalar: Real {
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
