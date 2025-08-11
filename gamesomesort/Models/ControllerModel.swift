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

  private(set) var models: [String: GEOModel] = [:]

  init(device: MTLDevice, controllerTexture: ControllerTexture) {
    self.device = device
    self.controllerTexture = controllerTexture
  }

  func loadModel(_ name: String) {
    let model = GEOModel(name: name, controllerTexture: controllerTexture, device: device)
    models[name] = model
  }

  @discardableResult
  func loadPrimitive(_ name: String, primitiveType: GEOPrimitive) -> GEOModel {
    let model = GEOModel(
      name: name,
      primitiveType: primitiveType,
      controllerTexture: controllerTexture,
      device: device
    )
    models[name] = model

    return model
  }
}
