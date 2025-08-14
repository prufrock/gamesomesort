//
//  ForwardRenderPass.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/15/25.
//

import MetalKit
import lecs_swift

struct RNDRGBufferRenderPass: RNDRRenderPass {
  let label = "G-Buffer Render Pass"
  private var descriptor: MTLRenderPassDescriptor?

  private let device: MTLDevice

  var pipelineState: MTLRenderPipelineState
  private let tbrPipelineState: MTLRenderPipelineState
  let depthStencilState: MTLDepthStencilState?

  // MARK: Debug lights vars
  let debugLights: Bool
  private let linePipelineState: MTLRenderPipelineState
  private let pointPipelineState: MTLRenderPipelineState

  // Don't let a reference to the shadow textue here keep it alive.
  weak var shadowTexture: MTLTexture?

  // The G-buffer textures
  // The colors of things
  var albedoTexture: MTLTexture?
  // World space normals of things
  var normalTexture: MTLTexture?
  // World space positions of things
  var positionTexture: MTLTexture?
  // How far away things are
  var depthTexture: MTLTexture?

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
    descriptor = MTLRenderPassDescriptor()
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
        $0.fragmentFunction = library.makeFunction(name: "tbr_fragment_gBuffer")
        $0.colorAttachments[0].pixelFormat = .invalid
        $0.depthAttachmentPixelFormat = depthPixelFormat
        $0.vertexDescriptor = MTLVertexDescriptor.defaultLayout
        // Add pixel formats for the additional GBuffer textures
        $0.colorAttachments[RenderTargetAlbedo.index].pixelFormat = .bgra8Unorm
        $0.colorAttachments[RenderTargetNormal.index].pixelFormat = .rgba16Float
        $0.colorAttachments[RenderTargetPosition.index].pixelFormat = .rgba16Float
      }
    )
  }

  // TODO: make sure this gets called by RNDRTileBasedDefferredRenderer when it's called.
  mutating func resize(_ dimensions: ScreenDimensions) {
    albedoTexture = Self.makeTexture(
      device: device,
      size: dimensions.cgSize,
      pixelFormat: .bgra8Unorm,  // colors can get away with lower precision
      label: "Albedo Texture",
    )

    normalTexture = Self.makeTexture(
      device: device,
      size: dimensions.cgSize,
      pixelFormat: .rgba16Float,
      label: "Normal Texture",
    )

    positionTexture = Self.makeTexture(
      device: device,
      size: dimensions.cgSize,
      pixelFormat: .rgba16Float,
      label: "Position Texture",
    )

    depthTexture = Self.makeTexture(
      device: device,
      size: dimensions.cgSize,
      pixelFormat: .depth32Float,
      label: "Depth Texture",
    )
  }

  func draw(
    commandBuffer: MTLCommandBuffer,
    ecs: LECSWorld,
    uniforms: SHDRUniforms,
    params: SHDRParams,
    context: RNDRContext
  ) {
    let textures = [albedoTexture, normalTexture, positionTexture]

    for (index, texture) in textures.enumerated() {
      // RenderTargetAlbedo is the first one, so add from there.
      let attachment = descriptor?.colorAttachments[RenderTargetAlbedo.index + index]
      attachment?.texture = texture
      // clear on the load action applys the clear color when adding the attachment
      attachment?.loadAction = .clear
      // store keeps the color texture between render passes
      attachment?.storeAction = .store
      // TODO: configure this clear color or use the configured clear color
      attachment?.clearColor = MTLClearColor(red: 0.73, green: 0.92, blue: 1, alpha: 1)
    }
    descriptor?.depthAttachment.texture = depthTexture
    descriptor?.depthAttachment.storeAction = .dontCare

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

    renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)

    let squares = ecs.models
    let sphere = context.controllerModel.models["brick-sphere.usdz"]!
    for square in squares {
      sphere.transform = square.transform
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
