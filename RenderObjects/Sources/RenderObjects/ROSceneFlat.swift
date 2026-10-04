//
//  ROSceneFlat.swift
//  RenderObjects
//
//  Created by David Kanenwisher on 9/29/26.
//

import VRTMath

public struct ROSceneFlat: ROScene {
  public let cameraPlayerOne: ROCameraFirstPerson
  public let lights: [ROLight]
  public let sun: ROPosition
  public let upVector: F3

  public init(
    cameraPlayerOne: ROCameraFirstPerson,
    lights: [ROLight],
    sun: ROPosition,
    upVector: F3
  ) {
    self.cameraPlayerOne = cameraPlayerOne
    self.lights = lights
    self.sun = sun
    self.upVector = upVector
  }
}
