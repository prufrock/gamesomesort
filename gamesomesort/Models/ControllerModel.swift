//
//  ControllerModel.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/10/25.
//

import MetalKit

// Manages models and makes them available to for the rest of the application.
// Should this be in RNDR?
class ControllerModel {
  private var device: MTLDevice
  private var controllerTexture: ControllerTexture
  private var worldBasis: F3

  private(set) var models: [String: GEOModel] = [:]

  init(
    device: MTLDevice,
    controllerTexture: ControllerTexture,
    worldBasis: F3
  ) {
    self.device = device
    self.controllerTexture = controllerTexture
    self.worldBasis = worldBasis
  }

  func loadModel(_ name: String) {
    var upright = GEOTransform()
    upright.scale = self.worldBasis

    let model = GEOModel(
      name: name,
      controllerTexture: controllerTexture,
      device: device,
      upright: upright
    )
    models[name] = model
  }

  @discardableResult
  func loadPrimitive(_ name: String, primitiveType: GEOPrimitive) -> GEOModel {
    var upright = GEOTransform()
    upright.scale = self.worldBasis

    let model = GEOModel(
      name: name,
      primitiveType: primitiveType,
      controllerTexture: controllerTexture,
      device: device,
      upright: upright
    )
    models[name] = model

    return model
  }
}
