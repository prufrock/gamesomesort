//
//  ROSceneFlat.swift
//  RenderObjects
//
//  Created by David Kanenwisher on 9/29/26.
//

public struct ROSceneFlat: ROScene {
  public let cameraPlayerOne: ROCameraFirstPerson

  public init(cameraPlayerOne: ROCameraFirstPerson) {
    self.cameraPlayerOne = cameraPlayerOne
  }
}
