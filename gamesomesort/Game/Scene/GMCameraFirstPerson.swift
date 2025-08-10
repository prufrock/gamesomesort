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
    Float4x4.perspectiveProjection(
      fov: fov,
      aspect: aspect,
      nearPlane: near,
      farPlane: far
    )
  }

  var viewMatrix: Float4x4 {
    (Float4x4.translate(position).rotate(quaternion).scale(scale)).inverse
  }

  var world: Float4x4 {
    Float4x4.translate(position).rotate(quaternion).scale(scale)
  }
}

// Extension to create the shadow camera for the first person camera.
extension GMCameraFirstPerson {
  // Remember: you may need to adjust this for cameras that aren't first person.
  // It may even be too much calculation if the game camera is an orthographic camera.
  func createShadowCamera(lightPosition: F3) -> GMCameraOrthographic {
    let nearPoints = calculatePlane(distance: near)
    let farPoints = calculatePlane(distance: far)

    // calculate bounding sphere of camera
    let radius1 = distance(nearPoints.lowerLeft, farPoints.upperRight) * 0.5
    let radius2 = distance(farPoints.lowerLeft, farPoints.upperRight) * 0.5
    var center: F3
    if radius1 > radius2 {
      center = simd_mix(nearPoints.lowerLeft, farPoints.upperRight, [0.5, 0.5, 0.5])
    } else {
      center = simd_mix(farPoints.lowerLeft, farPoints.upperRight, [0.5, 0.5, 0.5])
    }
    let radius = max(radius1, radius2)

    // create shadow camera using bounding sphere
    var shadowCamera = GMCameraOrthographic(transform: GEOTransform())
    let direction = normalize(lightPosition)
    shadowCamera.position = center + direction * radius
    shadowCamera.far = radius * 2
    shadowCamera.near = 0.01
    shadowCamera.viewSize = Float(shadowCamera.far)
    shadowCamera.center = center
    return shadowCamera
  }

  func calculatePlane(distance: Float) -> FrustrumPoints {
    let halfFov = self.fov * 0.5
    let halfHeight = tan(halfFov) * distance
    let halfWidth = halfHeight * aspect
    return calculatePlanePoints(
      matrix: viewMatrix,
      halfWidth: halfWidth,
      halfHeight: halfHeight,
      distance: distance,
      position: position
    )
  }

  func calculatePlanePoints(
    matrix: Float4x4,
    halfWidth: Float,
    halfHeight: Float,
    distance: Float,
    position: F3
  ) -> FrustrumPoints {
    let forwardVector: F3 = [matrix.columns.0.z, matrix.columns.1.z, matrix.columns.2.z]
    let rightVector: F3 = [matrix.columns.0.x, matrix.columns.1.x, matrix.columns.2.x]
    let upVector: F3 = cross(forwardVector, rightVector)
    let centerPoint = position + forwardVector * distance
    let moveRightBy = rightVector * halfWidth
    let moveDownBy = upVector * halfHeight

    let upperLeft = centerPoint - moveRightBy + moveDownBy
    let upperRight = centerPoint + moveRightBy + moveDownBy
    let lowerRight = centerPoint + moveRightBy - moveDownBy
    let lowerLeft = centerPoint - moveRightBy - moveDownBy
    let points = FrustrumPoints(
      viewMatrix: matrix,
      upperLeft: upperLeft,
      upperRight: upperRight,
      lowerRight: lowerRight,
      lowerLeft: lowerLeft,
    )
    return points
  }

  struct FrustrumPoints {
    var viewMatrix = Float4x4.identity
    var upperLeft: F3 = .zero
    var upperRight: F3 = .zero
    var lowerRight: F3 = .zero
    var lowerLeft: F3 = .zero
  }
}
