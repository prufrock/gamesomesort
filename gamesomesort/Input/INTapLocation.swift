//
//  INTapLocation.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/29/25.

import Foundation
import VRTMath

// Represents a tp location on the screen.
struct INTapLocation {
  let location: F2

  /// Converts from screen to NDC.
  /// - Parameters:
  /// - screenWidth: The width of the screen that corresponds with the coordinates.
  /// - screenHeight: The height of the screen that corresponds with the coordinates.
  /// - flipY: macOS has an origin in the lower left while iOS has the origin in the upper right so you need to flip y.
  /// - Returns:
  func screenToNdc(screenWidth: Float, screenHeight: Float, flipY: Bool = true) -> F2 {
    // divide position.x by the screenWidth so number varies between 0 and 1
    // multiply that by 2 so that it varies between 0 and 2
    // subtract 1 because NDC x increases as you go to the right and this moves the value between -1 and 1.
    // remember the abs(-1 - 1) = 2 so multiplying by 2 is important
    let x = ((location.x / screenWidth) * 2) - 1
    // converting position.y is like converting position.x
    // multiply by -1 when flipY is set because on iOS the origin is in the upper left
    let y = (flipY ? -1 : 1) * (((location.y / screenHeight) * 2) - 1)
    return Float2(x, y)  // ndc space
  }

  func screenToWorld(screenWidth: Float, screenHeight: Float, flipY: Bool = true, projection: Float4x4) -> F2 {
    let ndc = screenToNdc(screenWidth: screenWidth, screenHeight: screenHeight, flipY: flipY)
    let world = projection.inverse * F4(x: ndc.x, y: ndc.y, z: 1, w: 1)
    return world.xy
  }

  func screenToWorldOnZPlane(
    screenDimensions: ScreenDimensions,
    targetZPlaneWorldCoord: Float = 1.0,
    camera: GMCameraFirstPerson
  ) -> simd_float3? {

    // Convert to ND
    let ndc = screenToNdc(screenWidth: screenDimensions.pointWidth, screenHeight: screenDimensions.pointHeight)

    // Create a point(w=1.0) on the near plane
    let ndcPoint = F4(ndc.x, ndc.y, camera.near, 1.0)

    // Get the inverse of the Projection matrix to transforms from clip space to view space
    let inverseProjectionMatrix = camera.projection.inverse

    // Transform from NDC/Clip Space to View Space (camera space)
    var viewSpacePoint = inverseProjectionMatrix * ndcPoint
    // Don't forget the perspective divide or things get really crazy
    viewSpacePoint /= viewSpacePoint.w

    // Get the camera's world position because it's the rays origin.
    let inverseViewMatrix = camera.viewMatrix.inverse
    // It's position we want, so distill it down to just translation.
    let rayOrigin = inverseViewMatrix.translation

    // Need to find the location of other point(w=1.0) on the ray with the inverseViewMatrix to bring it into world space.
    let rayPointInWorld = inverseViewMatrix * F4(viewSpacePoint.x, viewSpacePoint.y, viewSpacePoint.z, 1.0)
    // Find a displacement vector along the ray, and normalize it to make it into a direction vector(w=0.0)
    let rayDirection = normalize(F3(rayPointInWorld.x, rayPointInWorld.y, rayPointInWorld.z) - rayOrigin)

    //TODO: need to understand this math a little better, it sets things up to find out where the ray intersects the plane
    let pointOnPlane = targetZPlaneWorldCoord
    let numerator = pointOnPlane - rayOrigin.z
    let denominator = rayDirection.z

    // Check to see if the denominator is so close to zero as to be practically parallel with the Z plane.
    if abs(denominator) < 1e-6 {
      print(
        "Ray is parallel to the Z=\(targetZPlaneWorldCoord) plane, so it can't intersect it. "
          + "If you need this you likely need to handle rotation differently."
      )
      return nil
    }

    let t = numerator / denominator

    // Ensure the intersection is in front of the camera (t >= 0)
    if t < 0 {
      print(
        "Intersection point is behind the ray origin. "
          + "If you need to support this you likely have to handle rotation differently."
      )
      return nil
    }

    // basic equation for finding where a ray intersects with a plane
    let intersectionPoint = rayOrigin + rayDirection * t

    return intersectionPoint
  }
}
