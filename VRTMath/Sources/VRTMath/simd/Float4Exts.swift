//
//  Float4Exts.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/17/26.
//

import simd
import RealModule

public typealias Float4 = SIMD4<Float>
public typealias F4 = Float4

public extension Float4 {
  var xy: Float2 {
    .init(x: x, y: y)
  }

  var xyz: Float3 {
    .init(x: x, y: y, z: z)
  }

  var perspectiveDivide: Float3 {
    Float3(
      x / w,
      y / w,
      z / w
    )
  }

  /// Converts a position from a Float2.
  /// w=1.0 so it can be translated.
  init(position value: F2) {
    self.init(value.x, value.y, 0.0, 1.0)
  }

  init(value: Float) {
    self.init(value, value, value, value)
  }
}

extension Float4 where Scalar: Real {
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
