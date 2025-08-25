//
//  RNDRTiledDeferredRenderPass.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/24/25.
//

import MetalKit
import lecs_swift

struct RNDRTiledDeferredRenderPass: RNDRRenderPass {
  let label = "Tiled Deferred Render Pass"
  private var descriptor: MTLRenderPassDescriptor?

  private let device: MTLDevice

  private let gBufferPipelineState: MTLRenderPipelineState
  private let depthStencilState: MTLDepthStencilState?

  // lighting pipelines
  private let sunlightPipeline: MTLRenderPipelineState
  private let pointLightPipeline: MTLRenderPipelineState
  private let lightingDepthStencilState: MTLDepthStencilState?


  // MARK: Debug lights vars
  let debugLights: Bool
  private let linePipelineState: MTLRenderPipelineState
  private let pointPipelineState: MTLRenderPipelineState

  // Don't let a reference to the shadow texture here keep it alive.
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
    tiled: Bool,
    debugLights: Bool = false
  ) {
    self.device = device
    self.debugLights = debugLights

    gBufferPipelineState = Self.buildGBufferPipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library
    )
    depthStencilState = Self.buildDepthStencilState(device: device)

    // lighting
    lightingDepthStencilState = Self.buildLightingDepthStencilState(device: device)
    sunlightPipeline = Self.buildSunLightPipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library,
      tiled: tiled
    )
    pointLightPipeline = Self.buildPointLightPipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library,
      tiled: tiled
    )

    // lighting debugging pipelines
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
  }

  private static func buildLightingDepthStencilState(device: MTLDevice) -> MTLDepthStencilState {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.isDepthWriteEnabled = false
    return device.makeDepthStencilState(descriptor: descriptor)!
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

  private static func buildGBufferPipelineState(
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

  private static func buildSunLightPipelineState(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary,
    tiled: Bool = false
  ) -> MTLRenderPipelineState {
    return try! device.makeRenderPipelineState(
      descriptor: MTLRenderPipelineDescriptor().apply {
        let vertexFunction = library.makeFunction(name: "tbr_vertex_quad")
        if vertexFunction == nil {
          fatalError("unable to load vertex_quad")
        }
        $0.vertexFunction = vertexFunction
        let fragment = tiled ? "tbr_fragment_tiled_deferredSun" : "tbr_fragment_deferredSun"
        let fragmentFunction = library.makeFunction(name: fragment)
        if fragmentFunction == nil {
          fatalError("unable to load \(fragment)")
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
    library: MTLLibrary,
    tiled: Bool = false
  ) -> MTLRenderPipelineState {
    return try! device.makeRenderPipelineState(
      descriptor: MTLRenderPipelineDescriptor().apply {
        guard let vertexFunction = library.makeFunction(name: "tbr_vertex_pointLight") else {
          fatalError("tbr_vertex_pointLight function not found")
        }
        $0.vertexFunction = vertexFunction

        let fragment = tiled ? "tbr_fragment_tiled_pointLight" : "tbr_fragment_pointLight"
        guard let fragmentFunction = library.makeFunction(name: "tbr_fragment_pointLight") else {
          fatalError("tbr_fragment_pointLight function not found")
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
    guard let currentDescriptor = descriptor else {
      fatalError("The descriptor is null, get out of my house!")
    }

    // GBuffer pass
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

    guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentDescriptor)
    else {
      fatalError("What in the world, the render command encoder couldn't be created!")
    }

    drawGBufferRenderPass(
      renderEncoder: renderEncoder,
      ecs: ecs,
      uniforms: uniforms,
      params: params,
      context: context
    )

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

  private func drawGBufferRenderPass(
    renderEncoder: MTLRenderCommandEncoder,
    ecs: LECSWorld,
    uniforms: SHDRUniforms,
    params: SHDRParams,
    context: RNDRContext
  ) {
    renderEncoder.label = label
    renderEncoder.setDepthStencilState(depthStencilState)
    renderEncoder.setRenderPipelineState(gBufferPipelineState)

    renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)

    let squares = ecs.models
    let sphere = context.controllerModel.models["brick-sphere.usdz"]!
    for square in squares {
      renderEncoder.pushDebugGroup("sphere \(sphere.position)")
      sphere.transform = square.transform
      sphere.render(
        encoder: renderEncoder,
        uniforms: uniforms,
        params: params
      )
      renderEncoder.popDebugGroup()
    }

    let models = ecs.geoModels(context: context)
    for model in models {
      renderEncoder.pushDebugGroup("model \(model.name)")
      model.render(encoder: renderEncoder, uniforms: uniforms, params: params)
      renderEncoder.popDebugGroup()
    }
  }
}
