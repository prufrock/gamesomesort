//
//  TextureController.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/15/25.
//

import MetalKit

class ControllerTexture {
  var textures: [String: MTLTexture] = [:]

  func loadTexture(texture: MDLTexture, name: String, device: MTLDevice) -> MTLTexture? {
    if let texture = textures[name] {
      return texture
    }
    let textureLoader = MTKTextureLoader(device: device)
    let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
      .origin: MTKTextureLoader.Origin.bottomLeft,
      .generateMipmaps: true,
    ]
    let texture = try? textureLoader.newTexture(
      texture: texture,
      options: textureLoaderOptions
    )
    textures[name] = texture
    return texture
  }

  func loadTexture(name: String, device: MTLDevice) -> MTLTexture? {
    if let texture = textures[name] {
      return texture
    }
    let textureLoader = MTKTextureLoader(device: device)
    let texture: MTLTexture?
    texture = try? textureLoader.newTexture(
      name: name,
      scaleFactor: 1.0,
      bundle: Bundle.main,
      options: nil
    )
    if texture != nil {
      textures[name] = texture
    }
    return texture
  }
}
