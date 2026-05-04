//
//  TBDGTapLocation.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/3/26.
//

import Foundation
import Testing
@testable import TileBasedGame
import VRTMath

@Test func `convert screen point to ndc point`() {
  let tapLocation = TBDGTapLocation(location: F2(0, 0))
  let result = tapLocation.screenToNdc(
    screenWidth: 100,
    screenHeight: 100
  )
  #expect(result == F2(-1.0, 1.0))
}

@Test func `convert screen point to world point`() {
  let tapLocation = TBDGTapLocation(location: F2(0, 0))
  let result = tapLocation.screenToWorld(
    screenWidth: 100,
    screenHeight: 100,
    projection: Float4x4.perspectiveProjection(
      fov: 90.f * DEG2RAD,
      aspect: 1.0,
      nearPlane: 0.1,
      farPlane: 1.0
    )
  )
  #expect(result.isClose(to: F2(-1.0, 1.0)))
}

@Test func `convert screen point to world point on Z plane`() {
  let tapLocation = TBDGTapLocation(location: F2(0, 0))
  let dimensions = VRTMScreenDimensions(
    pixelSize: CGSize(width: 100, height: 100),
    scaleFactor: 1.0
  )
  let camera = VRTMCameraPerspective(
    aspect: 1.0,
    far: 1.0,
    fov: 90.f * DEG2RAD,
    near: 0.1,
    transform: VRTMTransform()
  )

  let result = tapLocation.screenToWorldOnZPlane(
    screenDimensions: dimensions,
    camera: camera
  )!

  #expect(result.isClose(to: F3(-1.0, 1.0, 1.0)))
}
