//
//  RNDRLightingRenderPass.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/14/25.
//

import MetalKit
import lecs_swift

struct RNDRLightingRenderPass: RNDRRenderPass {
  let label = "Lighint Render Pass"
  private let device: MTLDevice
  // set this from the calling render pass, so it can get the descriptor from the view.
  var descriptor: MTLRenderPassDescriptor?
  var sunlightPipeline: MTLRenderPipelineState
  let depthStencilState: MTLDepthStencilState?

  weak var albedoTexture: MTLTexture?
  weak var normalTexture: MTLTexture?
  weak var positionTexture: MTLTexture?

  private static func buildSunLightPipelineState(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary
  ) -> MTLRenderPipelineState {
    return try! device.makeRenderPipelineState(
      descriptor: MTLRenderPipelineDescriptor().apply {
        $0.vertexFunction = library.makeFunction(name: "tbr_vertex_quad")
        $0.fragmentFunction = library.makeFunction(name: "tbr_fragment_deferredSun")
        $0.colorAttachments[0].pixelFormat = colorPixelFormat
        $0.depthAttachmentPixelFormat = depthPixelFormat
      }
    )
  }

  init(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary,
  ) {
    self.device = device

    sunlightPipeline = Self.buildSunLightPipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library
    )
    depthStencilState = Self.buildDepthStencilState(device: device)
  }

  func draw(
    commandBuffer: MTLCommandBuffer,
    ecs: LECSWorld,
    uniforms: SHDRUniforms,
    params: SHDRParams,
    context: RNDRContext,
  ) {
    guard let descriptor = descriptor,
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(
        descriptor: descriptor
      )
    else {
      return
    }
    renderEncoder.label = label
    renderEncoder.setDepthStencilState(depthStencilState)

    var uniforms = uniforms
    renderEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<SHDRUniforms>.stride,
      index: UniformsBuffer.index
    )


    renderEncoder.setFragmentTexture(
      albedoTexture,
      index: BaseColor.index
    )
    renderEncoder.setFragmentTexture(
      normalTexture,
      index: NormalTexture.index
    )
    renderEncoder.setFragmentTexture(
      positionTexture,
      index: PositionTexture.index
    )

    drawSunLight(
      renderEncoder: renderEncoder, ecs: ecs, params: params, context: context
    )
    renderEncoder.endEncoding()
  }

  func drawSunLight(
    renderEncoder: MTLRenderCommandEncoder,
    ecs: LECSWorld,
    params: SHDRParams,
    context: RNDRContext
  ) {
    renderEncoder.pushDebugGroup("Sun Light")
    renderEncoder.setRenderPipelineState(sunlightPipeline)
    var params = params
    params.lightCount = UInt32(context.sunLights.count)
    renderEncoder.setFragmentBytes(
      &params,
      length: MemoryLayout<SHDRParams>.stride,
      index: ParamsBuffer.index
    )
    renderEncoder.setFragmentBuffer(
      context.sunLightBuffer,
      offset: 0,
      index: LightBuffer.index
    )
    // draw the six verices of the quad
    renderEncoder.drawPrimitives(
      type: .triangle,
      vertexStart: 0,
      vertexCount: 6
    )
    renderEncoder.popDebugGroup()
  }
}
