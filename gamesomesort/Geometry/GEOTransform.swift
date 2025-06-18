//
//  GTransform.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/17/25.
//

struct GEOTransform {
  var position: Float3
  var quaternion: simd_quatf
  var scale: Float3
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
