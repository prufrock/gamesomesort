//
//  Float3Exts.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/17/26.
//

import simd

public typealias Float3 = SIMD3<Float>
public typealias F3 = Float3

public extension Float3 {
  var xy: F2 {
    F2(x: x, y: y)
  }

  static func quaternion(_ rotation: Float3) -> simd_quatf {
    simd_quatf(Float4x4.rotate(rotation))
  }
}
