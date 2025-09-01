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
  var descriptor: MTLRenderPassDescriptor?

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
      library: library,
      tiled: tiled
    )
    depthStencilState = Self.buildDepthStencilState(device: device)

    // lighting
    lightingDepthStencilState = Self.buildLightingDepthStencilState(device: device)
    sunlightPipeline = Self.buildSunLightPipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library,
      tiled: tiled,
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
    library: MTLLibrary,
    tiled: Bool = false
  ) -> MTLRenderPipelineState {
    return try! device.makeRenderPipelineState(
      descriptor: MTLRenderPipelineDescriptor().apply {
        $0.vertexFunction = library.makeFunction(name: "tbr_vertex_main")
        $0.fragmentFunction = library.makeFunction(name: "tbr_fragment_gBuffer")
        $0.colorAttachments[0].pixelFormat = .invalid
        if tiled {
          $0.colorAttachments[0].pixelFormat = colorPixelFormat
        }
        $0.depthAttachmentPixelFormat = .depth32Float_stencil8
        $0.stencilAttachmentPixelFormat = .depth32Float_stencil8
        $0.vertexDescriptor = MTLVertexDescriptor.defaultLayout
        $0.setGBufferPixelFormats()
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
        $0.depthAttachmentPixelFormat = .depth32Float_stencil8
        $0.stencilAttachmentPixelFormat = .depth32Float_stencil8
        if tiled {
          $0.setGBufferPixelFormats()
        }
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
        guard let fragmentFunction = library.makeFunction(name: fragment) else {
          fatalError("tbr_fragment_pointLight function not found")
        }
        $0.fragmentFunction = fragmentFunction
        $0.colorAttachments[0].pixelFormat = colorPixelFormat
        $0.depthAttachmentPixelFormat = .depth32Float_stencil8
        $0.stencilAttachmentPixelFormat = .depth32Float_stencil8
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
        if tiled {
          $0.setGBufferPixelFormats()
        }
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
      storageMode: .memoryless,
    )

    normalTexture = Self.makeTexture(
      device: device,
      size: dimensions.cgSize,
      pixelFormat: .rgba16Float,
      label: "Normal Texture",
      storageMode: .memoryless,
    )

    positionTexture = Self.makeTexture(
      device: device,
      size: dimensions.cgSize,
      pixelFormat: .rgba16Float,
      label: "Position Texture",
      storageMode: .memoryless,
    )

    depthTexture = Self.makeTexture(
      device: device,
      size: dimensions.cgSize,
      pixelFormat: .depth32Float_stencil8,
      label: "Depth Texture",
      storageMode: .memoryless,
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
      let attachment = currentDescriptor.colorAttachments[RenderTargetAlbedo.index + index]
      attachment?.texture = texture
      // clear on the load action applys the clear color when adding the attachment
      attachment?.loadAction = .clear
      // don't store the attachment, because tile based rendering keeps it in the GPU's memory
      attachment?.storeAction = .dontCare
      // TODO: configure this clear color or use the configured clear color
      attachment?.clearColor = MTLClearColor(red: 0.73, green: 0.92, blue: 1, alpha: 1)
    }
    currentDescriptor.depthAttachment.texture = depthTexture
    currentDescriptor.depthAttachment.storeAction = .dontCare
    currentDescriptor.stencilAttachment.texture = depthTexture
    currentDescriptor.stencilAttachment.storeAction = .dontCare

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

    // Render the lights
    drawLightingRenderPass(
      renderEncoder: renderEncoder,
      ecs: ecs,
      uniforms: uniforms,
      params: params,
      context: context
    )
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

  private func drawLightingRenderPass(
    renderEncoder: MTLRenderCommandEncoder,
    ecs: LECSWorld,
    uniforms: SHDRUniforms,
    params: SHDRParams,
    context: RNDRContext
  ) {
    renderEncoder.label = "Tiled Lighting render pass"
    renderEncoder.setDepthStencilState(lightingDepthStencilState)
    var uniforms = uniforms
    renderEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<SHDRUniforms>.stride,
      index: UniformsBuffer.index
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
  }

  private func drawSunLight(
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

extension MTLRenderPipelineDescriptor {
  func setGBufferPixelFormats() {
    // Add pixel formats for the additional GBuffer textures
  	colorAttachments[RenderTargetAlbedo.index].pixelFormat = .bgra8Unorm
    colorAttachments[RenderTargetNormal.index].pixelFormat = .rgba16Float
    colorAttachments[RenderTargetPosition.index].pixelFormat = .rgba16Float
  }
}
