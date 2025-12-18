//
//  RNDRTileBasedDeferredRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/14/25.
//
import MetalKit
import lecs_swift

class RNDRTileBasedDeferredRenderer: RNDRRenderer, RNDRContext {
  private let config: AppCoreConfig
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private let library: MTLLibrary
  private var forwardRenderPass: RNDRForwardRenderPass? = nil
  private var shadowRenderPass: RNDRShadowRenderPass? = nil
  private var tbdrPass: RNDRTiledDeferredRenderPass? = nil

  private var squareRenderer = RNDRSquare()

  private var screenDimensions = ScreenDimensions()

  var controllerTexture = ControllerTexture()
  var controllerModel: ControllerModel
  // TODO: remove once moved to the separate light buffers
  var lights: [SHDRLight] = []
  var lightBuffer: MTLBuffer? = nil
  var sunLights: [SHDRLight] = []
  var sunLightBuffer: MTLBuffer? = nil
  var pointLights: [SHDRLight] = []
  var pointLightBuffer: MTLBuffer? = nil

  init(config: AppCoreConfig) {
    self.config = config

    guard let newDevice = MTLCreateSystemDefaultDevice() else {
      fatalError(
        """
        I looked in the computer and didn't find a device...sorry
        """
      )
    }
    device = newDevice

    guard let newCommandQueue = device.makeCommandQueue() else {
      fatalError(
        """
        What?! No comand queue. Come on!
        """
      )
    }

    commandQueue = newCommandQueue

    guard let library = device.makeDefaultLibrary() else {
      fatalError(
        """
        Heckin' A! The library didn't load!
        """
      )
    }
    self.library = library

    squareRenderer.initBuffers(device: device)

    // Place holder controller, without models.
    controllerModel = ControllerModel(
      device: device,
      controllerTexture: controllerTexture,
      worldBasis: [1, 1, 1],
      worldUprightTransforms: [:]
    )
  }

  func resize(_ dimensions: ScreenDimensions) {
    screenDimensions = dimensions
    tbdrPass?.resize(dimensions)
  }

  func worldChanged(
    worldBasis: F3,
    worldUprightTransforms: [String: GEOTransform]
  ) {
    controllerModel = ControllerModel(
      device: device,
      controllerTexture: controllerTexture,
      worldBasis: worldBasis,
      worldUprightTransforms: worldUprightTransforms
    )

    config.services.renderService.models.forEach {
      controllerModel.loadModel($0)
    }

    controllerModel.loadPrimitive("back-plane", primitiveType: .plane)
    controllerModel.loadPrimitive("button-one", primitiveType: .plane)
    controllerModel.loadPrimitive("icosahedron", primitiveType: .icosahedron)
  }

  func initializePipelines(pixelFormat: MTLPixelFormat) {
    squareRenderer.initPipelines(device: device, library: library, pixelFormat: pixelFormat)
  }

  func initializeRenderPasses(pixelFormat: MTLPixelFormat, depthStencilPixelFormat: MTLPixelFormat) {

    shadowRenderPass = RNDRShadowRenderPass(
      device: device,
      depthPixelFormat: depthStencilPixelFormat,
      library: library,
      controllerTexture: controllerTexture,
    )

    forwardRenderPass = RNDRForwardRenderPass(
      device: device,
      colorPixelFormat: pixelFormat,
      depthPixelFormat: depthStencilPixelFormat,
      library: library,
      controllerTexture: controllerTexture
    )

    tbdrPass = RNDRTiledDeferredRenderPass(
      device: device,
      colorPixelFormat: pixelFormat,
      depthPixelFormat: depthStencilPixelFormat,
      library: library,
      controllerTexture: controllerTexture,
      tiled: true
    )
  }

  func createUniforms(_ ecs: LECSWorld) -> SHDRUniforms {
    let camera = ecs.gmCameraFirstPerson("playerCamera")!
    var uniforms = SHDRUniforms()

    uniforms.viewMatrix = camera.viewMatrix
    uniforms.projectionMatrix = camera.projection

    let sunlight = ecs.entity("sun")!
    let position = ecs.getComponent(sunlight, CTPosition3d.self)!
    let shadowCamera = camera.createShadowCamera(lightPosition: position.position)
    uniforms.shadowProjectionMatrix = shadowCamera.projection
    let upVector = config.game.upVector
    uniforms.shadowViewMatrix = Float4x4.lookAtProjection(
      eye: shadowCamera.position,
      center: shadowCamera.center,
      up: upVector
    )

    return uniforms
  }

  func createParams(_ ecs: LECSWorld) -> SHDRParams {
    let camera = ecs.gmCameraFirstPerson("playerCamera")!

    var params = SHDRParams()

    params.cameraPosition = camera.position

    return params
  }

  func render(ecs: LECSWorld, to renderDescriptor: SVCRenderDescriptor) {
    guard let commandBuffer = commandQueue.makeCommandBuffer() else {
      fatalError(
        """
        Ugh, no command buffer. They must be fresh out!
        """
      )
    }

    let uniforms = self.createUniforms(ecs)
    var params = self.createParams(ecs)

    updateLighting(ecs: ecs, params: &params)

    shadowRenderPass?.draw(commandBuffer: commandBuffer, world: ecs, uniforms: uniforms, params: params, context: self)

    switch config.services.renderService.tbdrRender {
    case .forward:
      if var forwardRenderPass {
        forwardRenderPass.shadowTexture = shadowRenderPass?.shadowTexture
        forwardRenderPass.descriptor = renderDescriptor.currentRenderPassDescriptor
        forwardRenderPass.draw(
          commandBuffer: commandBuffer,
          ecs: ecs,
          uniforms: uniforms,
          params: params,
          context: self
        )
      }
    case .tbdr:
      if var tbdrPass {
        tbdrPass.shadowTexture = shadowRenderPass!.shadowTexture
        tbdrPass.descriptor = renderDescriptor.currentRenderPassDescriptor
        tbdrPass.draw(
          commandBuffer: commandBuffer,
          ecs: ecs,
          uniforms: uniforms,
          params: params,
          context: self,
        )
      }
    }

    commandBuffer.present(renderDescriptor.currentDrawable)
    commandBuffer.commit()
  }

  func updateLighting(ecs: LECSWorld, params: inout SHDRParams) {
    lights = ecs.lights
    lightBuffer = device.makeBuffer(
      bytes: &lights,
      length: MemoryLayout<SHDRLight>.stride * lights.count,
      options: []
    )!
    sunLights = lights.filter { $0.type == Sun }
    sunLightBuffer = device.makeBuffer(
      bytes: &sunLights,
      length: MemoryLayout<SHDRLight>.stride * sunLights.count,
      options: []
    )!
    pointLights = lights.filter { $0.type == Point }
    pointLightBuffer = device.makeBuffer(
      bytes: &pointLights,
      length: MemoryLayout<SHDRLight>.stride * pointLights.count,
      options: []
    )
    params.lightCount = UInt32(lights.count)
  }
}

extension LECSWorld {
  var lights: [SHDRLight] {
    var lights: [SHDRLight] = []
    select([CTPosition3d.self, CTLight.self, CTColor.self]) { row, columns in
      let position = row.component(at: 0, columns, CTPosition3d.self)
      let light = row.component(at: 1, columns, CTLight.self)
      let color = row.component(at: 2, columns, CTColor.self)

      var shdrLight = SHDRLight()

      shdrLight.position = position.position
      shdrLight.radius = 0
      shdrLight.color = color.f3
      shdrLight.type = light.type
      shdrLight.coneDirection = light.coneDirection
      shdrLight.attenuation = light.attenuation
      shdrLight.coneAngle = light.coneAngle
      shdrLight.coneAttenutation = light.coneAttenuation
      shdrLight.coneDirection = light.coneDirection

      lights.append(shdrLight)
    }

    return lights
  }
}

// Shared information needed for rendering.
protocol RNDRContext {
  // TODO: remove once moved to the separate light buffers
  var lights: [SHDRLight] { get }
  // TODO: remove once moved to the separate light buffers
  var lightBuffer: MTLBuffer? { get }
  var pointLights: [SHDRLight] { get }
  var pointLightBuffer: MTLBuffer? { get }
  var sunLights: [SHDRLight] { get }
  var sunLightBuffer: MTLBuffer? { get }
  var controllerTexture: ControllerTexture { get }
  var controllerModel: ControllerModel { get }
}

enum RNDRTBDRRenderType: Int {
  case forward, tbdr
}
