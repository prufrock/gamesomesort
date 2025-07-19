//
//  ForwardRenderPass.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/15/25.
//

import MetalKit
import lecs_swift

struct ForwardRenderPass {
  let label = "Forward Render Pass"
  var descriptor: MTLRenderPassDescriptor?

  var pipelineState: MTLRenderPipelineState
  let depthStencilState: MTLDepthStencilState?

  init(device: MTLDevice, colorPixelFormat: MTLPixelFormat, depthPixelFormat: MTLPixelFormat, library: MTLLibrary) {
    pipelineState = Self.buildPipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library
    )
    depthStencilState = Self.buildDepthStencilState(device: device)
  }

  private static func buildPipelineState(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary
  ) -> MTLRenderPipelineState {
    return try! device.makeRenderPipelineState(
      descriptor: MTLRenderPipelineDescriptor().apply {
        $0.vertexFunction = library.makeFunction(name: "indexed_main")
        $0.fragmentFunction = library.makeFunction(name: "fragment_main")
        $0.colorAttachments[0].pixelFormat = colorPixelFormat
        $0.depthAttachmentPixelFormat = depthPixelFormat
        $0.vertexDescriptor = MTLVertexDescriptor().apply {
          // .position
          $0.attributes[Position.index].format = MTLVertexFormat.float3
          $0.attributes[Position.index].bufferIndex = VertexBuffer.index
          $0.attributes[Position.index].offset = 0
          $0.layouts[Position.index].stride = MemoryLayout<Float3>.stride
        }
      }
    )
  }

  private static func buildDepthStencilState(device: MTLDevice) -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    return device.makeDepthStencilState(descriptor: descriptor)
  }

  func draw(
    commandBuffer: MTLCommandBuffer,
    ecs: LECSWorld,
    uniforms: SHDRUniforms,
    params: SHDRParams
  ) {
    guard let descriptor = descriptor,
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
    else {
      fatalError(
        "Oh sheep on the beach! Couldn't draw from the forward render pass,"
          + " because the descriptor or render encoder was nil!"
      )
    }
    renderEncoder.label = label
    renderEncoder.setDepthStencilState(depthStencilState)
    renderEncoder.setRenderPipelineState(pipelineState)

    // lights...

    for model in ecs.models {
      model.render(
        encoder: renderEncoder,
        uniforms: uniforms,
        params: params
      )
    }
    renderEncoder.endEncoding()
  }
}

extension LECSWorld {
  var models: [RNDRModel] {
    []
  }
}

struct RNDRModel {
  func render(
    encoder: MTLRenderCommandEncoder,
    uniforms: SHDRUniforms,
    params: SHDRParams
  ) {
  }
}
