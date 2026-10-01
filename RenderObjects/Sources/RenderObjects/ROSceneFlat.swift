//
//  ROSceneFlat.swift
//  RenderObjects
//
//  Created by David Kanenwisher on 9/29/26.
//

import VRTMath

public struct ROSceneFlat: ROScene {
  public let cameraPlayerOne: ROCameraFirstPerson
  public let sun: ROLight
  public let upVector: F3

  public init(
    cameraPlayerOne: ROCameraFirstPerson,
    sun: ROLight,
    upVector: F3
  ) {
    self.cameraPlayerOne = cameraPlayerOne
    self.sun = sun
    self.upVector = upVector
  }
}
