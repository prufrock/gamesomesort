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
