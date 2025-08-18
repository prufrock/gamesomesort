//
//  RNDRLightingRenderPass.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/14/25.
//

import MetalKit
import lecs_swift

struct RNDRLightingRenderPass: RNDRRenderPass {
  let label = "Lighing Render Pass"
  private let device: MTLDevice
  // set this from the calling render pass, so it can get the descriptor from the view.
  var descriptor: MTLRenderPassDescriptor?
  var sunlightPipeline: MTLRenderPipelineState
  var pointLightPipeline: MTLRenderPipelineState
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
        guard let vertexFunction = library.makeFunction(name: "tbr_vertex_quad") else {
          fatalError("vertex function not found")
        }
        $0.vertexFunction = vertexFunction

        guard let fragmentFunction = library.makeFunction(name: "tbr_fragment_deferredSun") else {
          fatalError("fragment function not found")
        }
        $0.fragmentFunction = fragmentFunction

        $0.colorAttachments[0].pixelFormat = colorPixelFormat
        $0.depthAttachmentPixelFormat = depthPixelFormat
      }
    )
  }

  private static func buildPointLightPipelineState(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary
  ) -> MTLRenderPipelineState {
    return try! device.makeRenderPipelineState(
      descriptor: MTLRenderPipelineDescriptor().apply {
        guard let vertexFunction = library.makeFunction(name: "tbr_vertex_pointLight") else {
          fatalError("vertex function not found")
        }
        $0.vertexFunction = vertexFunction

        guard let fragmentFunction = library.makeFunction(name: "tbr_fragment_pointLight") else {
          fatalError("fragment function not found")
        }
        $0.fragmentFunction = fragmentFunction
        $0.colorAttachments[0].pixelFormat = colorPixelFormat
        $0.depthAttachmentPixelFormat = depthPixelFormat
        $0.vertexDescriptor = MTLVertexDescriptor.defaultLayout
        let attachment = $0.colorAttachments[0]!
        attachment.isBlendingEnabled = true
        attachment.rgbBlendOperation = .add
        attachment.alphaBlendOperation = .add
        attachment.sourceRGBBlendFactor = .one
        attachment.sourceAlphaBlendFactor = .one
        attachment.destinationRGBBlendFactor = .one
        attachment.destinationAlphaBlendFactor = .zero
        attachment.sourceRGBBlendFactor = .one
        attachment.sourceAlphaBlendFactor = .one
      }
    )
  }

  static func buildDepthStencilState(device: MTLDevice) -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    // the icosahredon should always render, so disable depth writes
    descriptor.isDepthWriteEnabled = true
    return device.makeDepthStencilState(descriptor: descriptor)
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
    pointLightPipeline = Self.buildPointLightPipelineState(
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
      renderEncoder: renderEncoder,
      ecs: ecs,
      params: params,
      context: context
    )

    drawPointLight(
      renderEncoder: renderEncoder,
      ecs: ecs,
      params: params,
      context: context
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

  func drawPointLight(
    renderEncoder: MTLRenderCommandEncoder,
    ecs: LECSWorld,
    params: SHDRParams,
    context: RNDRContext
  ) {
    renderEncoder.pushDebugGroup("Point Lights")
    renderEncoder.setRenderPipelineState(pointLightPipeline)

    renderEncoder.setVertexBuffer(
      context.pointLightBuffer,
      offset: 0,
      index: LightBuffer.index
    )
    renderEncoder.setFragmentBuffer(
      context.pointLightBuffer,
      offset: 0,
      index: LightBuffer.index
    )

    var params = params
    params.lightCount = UInt32(context.pointLights.count)
    renderEncoder.setFragmentBytes(
      &params,
      length: MemoryLayout<SHDRParams>.stride,
      index: ParamsBuffer.index
    )

    // pass the icosahedron to the vertex shader to render the light volume
    let icosahedron = context.controllerModel.models["icosahedron"]
    guard let mesh = icosahedron?.meshes.first, let submesh = mesh.submeshes.first else {
      fatalError("Ah dang, the something went wrong when getting the mesh or submesh out of the icosahedron.")
    }
    for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
      renderEncoder.setVertexBuffer(
        vertexBuffer,
        offset: 0,
        index: index
      )
    }

    renderEncoder.drawIndexedPrimitives(
      type: .triangle,
      indexCount: submesh.indexCount,
      indexType: submesh.indexType,
      indexBuffer: submesh.indexBuffer,
      indexBufferOffset: submesh.indexBufferOffset,
      instanceCount: context.pointLights.count
    )
    renderEncoder.popDebugGroup()
  }
}
