//
//  TBDGCameraPerspective.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/3/26.
//

public struct VRTMCameraPerspective: VRTMCamera {
  var aspect: Float
  var far: Float
  var fov: Float
  public var near: Float
  public var projection: Float4x4 {
    Float4x4.perspectiveProjection(
      fov: fov,
      aspect: aspect,
      nearPlane: near,
      farPlane: far
    )
  }
  public var transform: VRTMTransform
  public var viewMatrix: Float4x4 {
    (Float4x4.translate(position).rotate(quaternion).scale(scale)).inverse
  }
  var world: Float4x4 {
    Float4x4.translate(position).rotate(quaternion).scale(scale)
  }

  public init(
    aspect: Float,
    far: Float,
    fov: Float,
    near: Float,
    transform: VRTMTransform
  ) {
    self.aspect = aspect
    self.far = far
    self.fov = fov
    self.near = near
    self.transform = transform
  }
}
