//
//  ControllerModel.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/10/25.
//

import MetalKit
import VRTMath

// Manages models and makes them available to for the rest of the application.
// Should this be in RNDR?
class ControllerModel {
  private var device: MTLDevice
  private var controllerTexture: ControllerTexture
  private var worldBasis: F3
  private var worldUprightTransforms: [String: GEOTransform]

  private(set) var models: [String: GEOModel] = [:]

  init(
    device: MTLDevice,
    controllerTexture: ControllerTexture,
    worldBasis: F3,
    worldUprightTransforms: [String: GEOTransform]
  ) {
    self.device = device
    self.controllerTexture = controllerTexture
    self.worldBasis = worldBasis
    self.worldUprightTransforms = worldUprightTransforms
  }

  func loadModel(_ name: String) {
    let model = GEOModel(
      name: name,
      controllerTexture: controllerTexture,
      device: device,
      upright: self.uprightFor(model: name)
    )
    models[name] = model
  }

  @discardableResult
  func loadPrimitive(_ name: String, primitiveType: GEOPrimitive) -> GEOModel {
    let model = GEOModel(
      name: name,
      primitiveType: primitiveType,
      controllerTexture: controllerTexture,
      device: device,
      upright: self.uprightFor(model: name)
    )
    models[name] = model

    return model
  }

  func uprightFor(model name: String) -> GEOTransform {
    let uprightConfig = self.worldUprightTransforms[name] ?? GEOTransform()
    return GEOTransform(
      position: uprightConfig.position,
      quaternion: uprightConfig.quaternion,
      scale: self.worldBasis * uprightConfig.scale,
    )
  }
}
