//
//  ROCameraOrthographic.swift
//  RenderObjects
//
//  Created by David Kanenwisher on 9/26/26.
//

import simd
import VRTMath
private typealias Rect = VRTM2D.Rectangle

public struct GMCameraOrthographic: ROCamera {
  public var transform: ROTransform
  public var aspect: Float = 1
  public var viewSize: Float = 10
  public var near: Float = 0.1
  public var far: Float = 100
  public var center: F3 = .zero
}
