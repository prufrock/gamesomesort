//
//  ROTransform.swift
//  RenderObjects
//
//  Created by David Kanenwisher on 9/26/26.
//

import simd
import VRTMath

public struct ROTransform {
  public var position: Float3 = [0, 0, 0]
  public var quaternion: simd_quatf = float4x4.identity.q
  public var scale: Float3 = [1, 1, 1]

  public init(position: Float3, quaternion: simd_quatf, scale: Float3) {
    self.position = position
    self.quaternion = quaternion
    self.scale = scale
  }
}
