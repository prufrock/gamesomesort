//
//  RNDRTileBasedDeferredRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/14/25.
//
import LECSPieces
import MetalKit
import VRTMath
import lecs_swift

class RNDRTileBasedDeferredRenderer: RNDRRenderer, RNDRContext {
  private let config: AppCoreConfig
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private let library: MTLLibrary
  private var shadowRenderPass: RNDRShadowRenderPass? = nil
  private var tbdrPass: RNDRTiledDeferredRenderPass? = nil

  private var screenDimensions = VRTMScreenDimensions()

  var controllerTexture = ControllerTexture()
  var controllerModel: ControllerModel

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

    // Place holder controller, without models.
    controllerModel = ControllerModel(
      device: device,
      controllerTexture: controllerTexture,
      worldBasis: [1, 1, 1],
      worldUprightTransforms: [:]
    )
  }

  func resize(_ dimensions: VRTMScreenDimensions) {
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
    //no-op for now
  }

  func initializeRenderPasses(pixelFormat: MTLPixelFormat, depthStencilPixelFormat: MTLPixelFormat) {

    shadowRenderPass = RNDRShadowRenderPass(
      device: device,
      depthPixelFormat: depthStencilPixelFormat,
      library: library,
      controllerTexture: controllerTexture,
    )

    tbdrPass = RNDRTiledDeferredRenderPass(
      device: device,
      colorPixelFormat: pixelFormat,
      depthPixelFormat: depthStencilPixelFormat,
      library: library,
      controllerTexture: controllerTexture
    )
  }

  func createUniforms(_ ecs: LECSWorld) -> SHDRUniforms {
    let camera = ecs.gmCameraFirstPerson("playerCamera")!
    var uniforms = SHDRUniforms()

    uniforms.viewMatrix = camera.viewMatrix
    uniforms.projectionMatrix = camera.projection

    let sunlight = ecs.entity("sun")!
    let position = ecs.getComponent(sunlight, LECSPPosition3d.self)!
    let shadowCamera = camera.createShadowCamera(lightPosition: position.position)
    uniforms.shadowProjectionMatrix = shadowCamera.projection
    let upVector = config.game.upVector
    uniforms.shadowViewMatrix =
      Float4x4.scale(camera.scale)
      * Float4x4.lookAtProjection(
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

    shadowRenderPass?.draw(
      commandBuffer: commandBuffer,
      world: ecs,
      uniforms: uniforms,
      params: params,
      context: self
    )

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

    commandBuffer.present(renderDescriptor.currentDrawable)
    commandBuffer.commit()
  }

  func updateLighting(ecs: LECSWorld, params: inout SHDRParams) {
    let lights = ecs.lights

    sunLights = lights.filter { $0.type == Sun }
    sunLightBuffer = device.makeBuffer(
      bytes: &sunLights,
      length: MemoryLayout<SHDRLight>.stride * sunLights.count,
      options: []
    )

    pointLights = lights.filter { $0.type == Point }
    if pointLights.isNotEmpty {
      pointLightBuffer = device.makeBuffer(
        bytes: &pointLights,
        length: MemoryLayout<SHDRLight>.stride * pointLights.count,
        options: []
      )
    }
  }
}
