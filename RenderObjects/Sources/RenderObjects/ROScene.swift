//
//  ROScene.swift
//  RenderObjects
//
//  Created by David Kanenwisher on 9/26/26.
//

import VRTMath

public protocol ROScene {
  var cameraPlayerOne: ROCameraFirstPerson {get}
  var lights: [ROLight] {get}
  var sun: ROPosition {get}
  var upVector: F3 {get}
}
