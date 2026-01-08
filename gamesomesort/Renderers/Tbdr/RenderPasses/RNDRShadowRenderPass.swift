//
//  RNDRShadowRenderPass.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/29/25.
//

import MetalKit
import lecs_swift

struct RNDRShadowRenderPass: RNDRRenderPass {
  let label: String = "Shadow Render Pass"
  var descriptor: MTLRenderPassDescriptor? = MTLRenderPassDescriptor()
  var depthStencilState: MTLDepthStencilState?
  var pipelineState: MTLRenderPipelineState
  var shadowTexture: MTLTexture?

  init(
    device: MTLDevice,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary,
    controllerTexture: ControllerTexture
  ) {
    depthStencilState = Self.buildDepthStencilState(device: device)
    pipelineState = Self.buildPipelineState(device: device, depthPixelFormat: depthPixelFormat, library: library)
    // write the shadow calculations to here
    shadowTexture = Self.makeTexture(
      device: device,
      size: .init(width: 2048, height: 2048),
      pixelFormat: depthPixelFormat,
      label: "Shadow Depth Texture"
    )
  }

  private static func buildPipelineState(
    device: MTLDevice,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary
  ) -> MTLRenderPipelineState {
    return try! device.makeRenderPipelineState(
      descriptor: MTLRenderPipelineDescriptor().apply {
        $0.vertexFunction = library.makeFunction(name: "vertex_depth")
        $0.colorAttachments[0].pixelFormat = .invalid
        $0.depthAttachmentPixelFormat = depthPixelFormat
        $0.vertexDescriptor = .defaultLayout
      }
    )
  }

  func draw(
    commandBuffer: MTLCommandBuffer,
    world: LECSWorld,
    uniforms: SHDRUniforms,
    params: SHDRParams,
    context: RNDRContext
  ) {
    guard let descriptor = descriptor else { return }
    // store the calculations in the shadow texture
    descriptor.depthAttachment.texture = shadowTexture
    descriptor.depthAttachment.loadAction = .clear
    descriptor.depthAttachment.storeAction = .store

    guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
      return
    }
    renderEncoder.label = "Shadow Encoder"
    renderEncoder.setDepthStencilState(depthStencilState)
    renderEncoder.setRenderPipelineState(pipelineState)

    renderEncoder.setFragmentBuffer(
      context.lightBuffer!,
      offset: 0,
      index: LightBuffer.index
    )

    let models = world.gameObjects(context: context)
    for model in models {
      renderEncoder.pushDebugGroup("model \(model.name)")
      model.render(encoder: renderEncoder, uniforms: uniforms, params: params)
      renderEncoder.popDebugGroup()
    }

    renderEncoder.endEncoding()
  }
}
