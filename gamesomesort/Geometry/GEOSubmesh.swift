//
//  GEOSubmesh.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/15/25.
//

import MetalKit

struct GEOSubmesh {
  let indexCount: Int
  let indexType: MTLIndexType
  let indexBuffer: MTLBuffer
  let indexBufferOffset: Int

  struct Textures {
    var baseColor: MTLTexture?
    var normal: MTLTexture?
    var roughness: MTLTexture?
    var metallic: MTLTexture?
    var aoTexture: MTLTexture?

    init(material: MDLMaterial?, textureController: ControllerTexture, device: MTLDevice) {
      baseColor = material?.texture(type: .baseColor, textureController: textureController, device: device)
    }
  }

  var textures: Textures
  var material: SHDRMaterial

  init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh, textureController: ControllerTexture, device: MTLDevice) {
    indexCount = mtkSubmesh.indexCount
    indexType = mtkSubmesh.indexType
    indexBuffer = mtkSubmesh.indexBuffer.buffer
    indexBufferOffset = mtkSubmesh.indexBuffer.offset
    textures = Textures(material: mdlSubmesh.material, textureController: textureController, device: device)
    material = SHDRMaterial(material: mdlSubmesh.material)
  }
}

extension MDLMaterialProperty {
  fileprivate var textureName: String {
    stringValue ?? UUID().uuidString
  }
}

extension MDLMaterial {
  fileprivate func texture(
    type semantic: MDLMaterialSemantic,
    textureController: ControllerTexture,
    device: MTLDevice
  ) -> MTLTexture? {
    if let property = property(with: semantic),
      property.type == .texture,
      let mdlTexture = property.textureSamplerValue?.texture
    {
      return textureController.loadTexture(texture: mdlTexture, name: property.textureName, device: device)
    }
    return nil
  }
}

extension SHDRMaterial {
  fileprivate init(material: MDLMaterial?) {
    self.init()
    if let baseColor = material?.property(with: .baseColor), baseColor.type == .float3 {
      self.baseColor = baseColor.float3Value
    }
    if let roughness = material?.property(with: .roughness), roughness.type == .float {
      self.roughness = roughness.floatValue
    }
    if let metallic = material?.property(with: .metallic), metallic.type == .float {
      self.metallic = metallic.floatValue
    }
    self.ambientOcclusion = 1
  }
}
