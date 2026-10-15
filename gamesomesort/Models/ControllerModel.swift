//
//  ControllerModel.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/10/25.
//

import MetalKit
import VRTMath

// Manages models and makes them available for the rest of the application.
// Should this be in RNDR?
class ControllerModel {
  private var device: MTLDevice
  private var controllerTexture: ControllerTexture
  private var worldBasis: F3
  private var worldUprightTransforms: [String: GEOTransform]
  // experimenting with buffers
  private var maxBufferObjects: Int = 500
  private var maxBufferSize: Int {
    MemoryLayout<Float4x4>.stride * maxBufferObjects
  }
  private(set) var transformBuffers: [String: MTLBuffer] = [:]

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

  func loadModel(_ config: AppCoreConfig.Services.RenderService.ModelConfig) {
    let model = GEOModel(
      name: config.name,
      controllerTexture: controllerTexture,
      device: device,
      upright: self.uprightFor(model: config.name),
      renderInstanced: config.renderInstanced
    )
    models[config.name] = model
    transformBuffers[config.name] = device.makeBuffer(length: maxBufferSize)
  }

  @discardableResult
  func loadPrimitive(_ name: String, primitiveType: GEOPrimitive) -> GEOModel {
    let model = GEOModel(
      name: name,
      primitiveType: primitiveType,
      controllerTexture: controllerTexture,
      device: device,
      upright: self.uprightFor(model: name),
      renderInstanced: true
    )
    models[name] = model
    transformBuffers[name] = device.makeBuffer(length: maxBufferSize)

    return model
  }

  func updateTransformsBuffer(forModel name: String, with transforms: [Float4x4]) {
    guard !transforms.isEmpty else {
      return
    }

    // Fail if there are too many
    let requestedSize = MemoryLayout<Float4x4>.stride * transforms.count
    if requestedSize > maxBufferSize {
      fatalError("Tried to add \(requestedSize) transforms, max is \(maxBufferSize).")
    }

    let destPointer = transformBuffers[name]!.contents()

    transforms.withUnsafeBytes { rawBuffer in
      let sourcePointer = rawBuffer.baseAddress!
      memcpy(destPointer, sourcePointer, requestedSize)
    }
  }

  private func uprightFor(model name: String) -> GEOTransform {
    let uprightConfig = self.worldUprightTransforms[name] ?? GEOTransform()
    return GEOTransform(
      position: uprightConfig.position,
      quaternion: uprightConfig.quaternion,
      scale: self.worldBasis * uprightConfig.scale,
    )
  }
}
