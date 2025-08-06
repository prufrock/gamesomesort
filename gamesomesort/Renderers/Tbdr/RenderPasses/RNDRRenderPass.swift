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
}
