//
//  Float4Exts.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/17/26.
//

import simd

public typealias Float4 = SIMD4<Float>
public typealias F4 = Float4

public extension Float4 {
  var xy: Float2 {
    .init(x: x, y: y)
  }

  var xyz: Float3 {
    .init(x: x, y: y, z: z)
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
