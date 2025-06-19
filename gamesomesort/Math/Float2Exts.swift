//
//  Float2Exts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

import simd

typealias Float2 = SIMD2<Float>
typealias F2 = Float2

extension Float2 {
  var length: Float {
    (x * x + y * y).squareRoot()
  }
}
