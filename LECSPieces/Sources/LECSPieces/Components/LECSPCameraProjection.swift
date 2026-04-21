//
//  LECSPCamera.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 4/20/26.
//

import lecs_swift

public typealias LECSPCameraFirstPerson = LECSPCameraProjection

public struct LECSPCameraProjection: LECSComponent {
  public var fov: Float
  public var nearPlane: Float
  public var farPlane: Float

  public init() {
    self.fov = 1.0
    self.nearPlane = 0.0
    self.farPlane = 0.0
  }

  public init(fov: Float, nearPlane: Float, farPlane: Float) {
    self.fov = fov
    self.nearPlane = nearPlane
    self.farPlane = farPlane
  }
}
