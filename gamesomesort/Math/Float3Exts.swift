//
//  Float3Exts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/6/25.
//

import simd

public typealias Float3 = SIMD3<Float>
public typealias F3 = Float3

extension Float3 {
  var xy: F2 {
    F2(x: x, y: y)
  }

  static func quaternion(_ rotation: Float3) -> simd_quatf {
    simd_quatf(Float4x4.rotate(rotation))
  }
}
