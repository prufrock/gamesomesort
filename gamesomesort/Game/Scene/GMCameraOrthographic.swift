//
//  GMCameraOrthographic.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/5/25.
//

import VRTMath
private typealias Rect = VRTM2D.Rectangle

struct GMCameraOrthographic: GMCamera {
  var transform: GEOTransform
  var aspect: Float = 1
  var viewSize: Float = 10
  var near: Float = 0.1
  var far: Float = 100
  var center: F3 = .zero

  var viewMatrix: Float4x4 {
    (float4x4.translate(center).rotate(quaternion)).inverse
  }

  var projection: Float4x4 {
    let rect = Rect(x: -viewSize * aspect * 0.5, y: viewSize * 0.5, width: viewSize * aspect, height: viewSize)
    return float4x4.orthographicProjection(rect: rect, near: near, far: far)
  }
}
