//
//  GTransform.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/17/25.
//

import VRTMath

struct GEOTransform {
  var position: Float3 = [0, 0, 0]
  var quaternion: simd_quatf = simd_quatf(float4x4.identity)
  var scale: Float3 = [1, 1, 1]
}

extension GEOTransform {
  var modelMatrix: Float4x4 {
    let translation = Float4x4.translate(position)
    let rotation = Float4x4(quaternion)
    let scale = Float4x4.scale(scale)
    let modelMatrix = translation * rotation * scale
    return modelMatrix
  }
}

extension GEOTransform {
  static func * (lhs: GEOTransform, rhs: GEOTransform) -> GEOTransform {
    var result = lhs
    result.position += rhs.position
    result.scale *= rhs.scale
    result.quaternion *= rhs.quaternion
    return result
  }
}
