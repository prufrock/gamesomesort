//
//  ROCameraFirstPerson.swift
//  RenderObjects
//
//  Created by David Kanenwisher on 9/26/26.
//

import simd
import VRTMath

public struct ROCameraFirstPerson: ROCamera {
  public var transform: ROTransform
  public var aspect: Float
  public var fov: Float
  public var near: Float
  public var far: Float

  public init(transform: ROTransform, aspect: Float, fov: Float, near: Float, far: Float) {
    self.transform = transform
    self.aspect = aspect
    self.fov = fov
    self.near = near
    self.far = far
  }
}
