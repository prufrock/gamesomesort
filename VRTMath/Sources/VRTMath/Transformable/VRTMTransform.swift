//
//  VRTMTransform.swift
//  VRTMath
//
//  Created by David Kanenwisher on 5/3/26.
//

import simd

/// VRTMTransoform encapsulates all the necessary attributes
/// for 3D transformations.
public struct VRTMTransform {
  public var position: Float3 = [0, 0, 0]
  public var quaternion: simd_quatf = Float4x4.identity.q
  public var scale: Float3 = [1, 1, 1]

  public init(
    position: Float3 = [0, 0, 0],
    quaternion: simd_quatf = Float4x4.identity.q,
    scale: Float3 = [1, 1, 1]
  ) {
    self.position = position
    self.quaternion = quaternion
    self.scale = scale
  }
}

public extension VRTMTransform {
  var modelMatrix: Float4x4 {
    let translation = Float4x4.translate(position)
    let rotation = Float4x4(quaternion)
    let scale = Float4x4.scale(scale)
    let modelMatrix = translation * rotation * scale
    return modelMatrix
  }
}

public extension VRTMTransform {
  static func * (lhs: VRTMTransform, rhs: VRTMTransform) -> VRTMTransform {
    var result = lhs
    result.position += rhs.position
    result.scale *= rhs.scale
    result.quaternion *= rhs.quaternion
    return result
  }
}
