//
//  ForwardRenderPass.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/15/25.
//

import MetalKit
import lecs_swift

struct RNDRForwardRenderPass: RNDRRenderPass {
  let label = "Forward Render Pass"
  var descriptor: MTLRenderPassDescriptor?
  let debugLights: Bool

  private let device: MTLDevice

  var pipelineState: MTLRenderPipelineState
  private let tbrPipelineState: MTLRenderPipelineState
  private let linePipelineState: MTLRenderPipelineState
  private let pointPipelineState: MTLRenderPipelineState
  let depthStencilState: MTLDepthStencilState?

  // Don't let a reference to the shadow textue here keep it alive.
  weak var shadowTexture: MTLTexture?

  init(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary,
    controllerTexture: ControllerTexture,
    debugLights: Bool = false
  ) {
    self.device = device
    self.debugLights = debugLights

    pipelineState = Self.buildPipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library
    )
    tbrPipelineState = Self.buildTbrPipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library
    )
    linePipelineState = Self.buildLightDebugLinePipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library
    )
    pointPipelineState = Self.buildLightDebugPointPipelineState(
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

  private static func buildLightDebugLinePipelineState(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary
  ) -> MTLRenderPipelineState {
    try! device.makeRenderPipelineState(
      descriptor: RNDRDebugLights.linePipelineStateDescriptor(
        library: library,
        colorPixelFormat: colorPixelFormat,
        depthPixelFormat: depthPixelFormat
      )
    )
  }

  private static func buildLightDebugPointPipelineState(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary
  ) -> MTLRenderPipelineState {
    try! device.makeRenderPipelineState(
      descriptor: RNDRDebugLights.pointPipelineStateDescriptor(
        library: library,
        colorPixelFormat: colorPixelFormat,
        depthPixelFormat: depthPixelFormat
      )
    )
  }

  private static func buildTbrPipelineState(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary
  ) -> MTLRenderPipelineState {
    return try! device.makeRenderPipelineState(
      descriptor: MTLRenderPipelineDescriptor().apply {
        $0.vertexFunction = library.makeFunction(name: "tbr_vertex_main")
        $0.fragmentFunction = library.makeFunction(name: "tbr_fragment_main")
        $0.colorAttachments[0].pixelFormat = colorPixelFormat
        $0.depthAttachmentPixelFormat = depthPixelFormat
        $0.vertexDescriptor = MTLVertexDescriptor.defaultLayout
      }
    )
  }

  func draw(
    commandBuffer: MTLCommandBuffer,
    ecs: LECSWorld,
    uniforms: SHDRUniforms,
    params: SHDRParams,
    context: RNDRContext
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
    renderEncoder.setRenderPipelineState(tbrPipelineState)

    renderEncoder.setFragmentBuffer(
      context.lightBuffer!,
      offset: 0,
      index: LightBuffer.index
    )
    renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)

    let squares = ecs.models
    let sphere = context.controllerModel.models["brick-sphere.usdz"]!
    for square in squares {
      sphere.upright = square.transform
      sphere.render(
        encoder: renderEncoder,
        uniforms: uniforms,
        params: params
      )
    }

    let models = ecs.geoModels(context: context)
    for model in models {
      model.render(encoder: renderEncoder, uniforms: uniforms, params: params)
    }

    if debugLights {
      RNDRDebugLights
        .draw(
          device: device,
          lights: context.lights,
          encoder: renderEncoder,
          uniforms: uniforms,
          linePipelineState: linePipelineState,
          pointPipelineState: pointPipelineState
        )
    }
    renderEncoder.endEncoding()
  }
}

extension GEOModel {
  func render(
    encoder: MTLRenderCommandEncoder,
    uniforms: SHDRUniforms,
    params: SHDRParams,
    gameObject: RNDRGameObject? = nil
  ) {
    var uniforms = uniforms
    var params = params
    params.tiling = tiling

    let baseColor: F3? = gameObject?.baseColor
    let transforms = (gameObject?.transform ?? GEOTransform()) * self.upright

    if let baseColor {
      meshes[0].submeshes[0].material.baseColor = baseColor
    }

    uniforms.modelMatrix = transforms.modelMatrix
    uniforms.normalMatrix = uniforms.modelMatrix.upperLeft

    encoder.setVertexBytes(&uniforms, length: MemoryLayout<SHDRUniforms>.stride, index: UniformsBuffer.index)

    encoder.setFragmentBytes(&params, length: MemoryLayout<SHDRParams>.stride, index: ParamsBuffer.index)

    for mesh in meshes {
      for (index, verteBuffer) in mesh.vertexBuffers.enumerated() {
        encoder.setVertexBuffer(verteBuffer, offset: 0, index: index)
      }

      for submesh in mesh.submeshes {

        var material = submesh.material
        encoder.setFragmentBytes(&material, length: MemoryLayout<SHDRMaterial>.stride, index: MaterialBuffer.index)

        encoder.setFragmentTexture(submesh.textures.baseColor, index: BaseColor.index)
        encoder.setFragmentTexture(submesh.textures.normal, index: NormalTexture.index)
        encoder.setFragmentTexture(submesh.textures.roughness, index: RoughnessTexture.index)
        encoder.setFragmentTexture(submesh.textures.metallic, index: MetallicTexture.index)
        encoder.setFragmentTexture(submesh.textures.aoTexture, index: AOTexture.index)
        // Being explicit for a little bit, because of an unexpected issue with stencils...
        encoder.setFrontFacing(.clockwise)
        encoder.setCullMode(.back)

        encoder.drawIndexedPrimitives(
          type: .triangle,
          indexCount: submesh.indexCount,
          indexType: submesh.indexType,
          indexBuffer: submesh.indexBuffer,
          indexBufferOffset: submesh.indexBufferOffset
        )
      }
    }
  }
}
