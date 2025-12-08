//
//  RNDRRenderPass.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/29/25.
//

import MetalKit
import lecs_swift

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
  var models: [GMSquare] {
    var squares = [GMSquare]()
    select([LECSPosition2d.self, CTColor.self, CTRadius.self, CTTagVisible.self]) { row, columns in
      let position = row.component(at: 0, columns, LECSPosition2d.self)
      let color = row.component(at: 1, columns, CTColor.self)
      let radius = row.component(at: 2, columns, CTRadius.self)
      let square = GMSquare(
        transform: GEOTransform(
          position: F3(position.position, 1.0),
          quaternion: simd_quatf(Float4x4.identity),
          scale: Float3(repeating: radius.radius)
        ),
        color: color.color
      )
      squares.append(square)
    }
    return squares
  }

  func geoModels(context: RNDRContext) -> [GEOModel] {
    var models = [GEOModel]()
    select(
      [
        CTModel.self,
        CTPosition3d.self,
        CTScale3d.self,
        CTQuaternion.self,
        CTColor.self,
        CTTagVisible.self,
      ]
    ) { row, columns in
      let ctModel = row.component(at: 0, columns, CTModel.self)
      let position = row.component(at: 1, columns, CTPosition3d.self)
      let scale = row.component(at: 2, columns, CTScale3d.self)
      let quaternion = row.component(at: 3, columns, CTQuaternion.self)
      let color = row.component(at: 4, columns, CTColor.self)

      //TODO: models need to be separate from transforms and eventually textures
      let model = context.controllerModel.models[ctModel.name]!
      model.transform.scale = scale.scale
      model.transform.quaternion = quaternion.quaternion
      model.transform.position = position.position
      model.meshes[0].submeshes[0].material.baseColor = color.f3

      models.append(model)
    }
    return models
  }

  func gameObjects(context: RNDRContext) -> [RNDRGameObject] {
    var gameObjects = [RNDRGameObject]()
    select(
      [
        CTModel.self,
        CTPosition3d.self,
        CTScale3d.self,
        CTQuaternion.self,
        CTColor.self,
        CTTagVisible.self,
      ]
    ) { row, columns in
      let ctModel = row.component(at: 0, columns, CTModel.self)
      let position = row.component(at: 1, columns, CTPosition3d.self)
      let scale = row.component(at: 2, columns, CTScale3d.self)
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
