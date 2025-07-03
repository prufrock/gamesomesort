//
//  GMFirstPersonCamera.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/17/25.
//

struct GMCameraFirstPerson: GMCamera {
  var transform: GEOTransform
  var aspect: Float
  var fov: Float
  var near: Float
  var far: Float
  var projection: Float4x4 {
    Float4x4.perspectiveProjection(fov: fov, aspect: aspect, nearPlane: near, farPlane: far)
  }

  var viewMatrix: Float4x4 {
    (Float4x4.translate(position).rotate(quaternion).scale(scale)).inverse
  }

  var world: Float4x4 {
    Float4x4.translate(position).rotate(quaternion).scale(scale)
  }
}
