//
//  Float2Exts.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/17/26.
//

import simd

public typealias Float2 = SIMD2<Float>
public typealias F2 = Float2

public extension Float2 {
  var length: Float {
    (x * x + y * y).squareRoot()
  }
}
