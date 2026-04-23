//
//  RNDRRenderPass.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/29/25.
//

import MetalKit
import lecs_swift
import VRTMath
import LECSPieces

protocol RNDRRenderPass {

}

extension RNDRRenderPass {
  static func buildDepthStencilState(device: MTLDevice) -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    return device.makeDepthStencilState(descriptor: descriptor)
  }

  static func makeTexture(
    device: MTLDevice,
    size: CGSize,
    pixelFormat: MTLPixelFormat,
    label: String,
    storageMode: MTLStorageMode = .private,
    usage: MTLTextureUsage = [.shaderRead, .renderTarget]
  ) -> MTLTexture? {
    let width = Int(size.width)
    let height = Int(size.height)
    guard width > 0 && height > 0 else { return nil }
    let textureDesc = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: pixelFormat,
      width: width,
      height: height,
      mipmapped: false
    )
    textureDesc.usage = usage
    textureDesc.storageMode = storageMode

    guard let texture = device.makeTexture(descriptor: textureDesc) else {
      fatalError("Oh no! The texture \(label) could not be created!")
    }
    texture.label = label
    return texture
  }
}

extension LECSWorld {

  func gameObjects(context: RNDRContext) -> [RNDRGameObject] {
    var gameObjects = [RNDRGameObject]()
    select(
      [
        CTModel.self,
        LECSPPosition3d.self,
        LECSPScale3d.self,
        CTQuaternion.self,
        CTColor.self,
        CTTagVisible.self,
      ]
    ) { row, columns in
      let ctModel = row.component(at: 0, columns, CTModel.self)
      let position = row.component(at: 1, columns, LECSPPosition3d.self)
      let scale = row.component(at: 2, columns, LECSPScale3d.self)
      let quaternion = row.component(at: 3, columns, CTQuaternion.self)
      let color = row.component(at: 4, columns, CTColor.self)

      let gameObject = RNDRGameObject(
        name: ctModel.name,
        transform: GEOTransform(
          position: position.position,
          quaternion: quaternion.quaternion,
          scale: scale.scale
        ),
        model: context.controllerModel.models[ctModel.name]!,
        baseColor: color.f3
      )

      gameObjects.append(gameObject)
    }
    return gameObjects
  }
}
