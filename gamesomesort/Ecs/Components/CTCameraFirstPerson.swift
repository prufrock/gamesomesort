//
//  CTCamera.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/17/25.
//

import lecs_swift

struct CTCameraFirstPerson: LECSComponent {
  var fov: Float
  var nearPlane: Float
  var farPlane: Float

  init() {
    self.fov = 1.0
    self.nearPlane = 0.0
    self.farPlane = 0.0
  }

  init(fov: Float, nearPlane: Float, farPlane: Float) {
    self.fov = fov
    self.nearPlane = nearPlane
    self.farPlane = farPlane
  }
}
