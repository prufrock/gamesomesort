//
//  RNDRTileBasedDeferredRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/14/25.
//
import MetalKit
import RenderObjects
import VRTMath

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

    config.services.renderService.modelConfig.forEach {
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

  func render(scene: ROScene, to renderDescriptor: SVCRenderDescriptor) {
    let scene = RNDRScene(scene: scene, controllerModel: controllerModel)

    guard let commandBuffer = commandQueue.makeCommandBuffer() else {
      fatalError(
        """
        Ugh, no command buffer. They must be fresh out!
        """
      )
    }

    updateLighting(scene: scene)

    shadowRenderPass?.draw(
      commandBuffer: commandBuffer,
      scene: scene,
      context: self
    )

    if var tbdrPass {
      tbdrPass.shadowTexture = shadowRenderPass!.shadowTexture
      tbdrPass.descriptor = renderDescriptor.currentRenderPassDescriptor
      tbdrPass.draw(
        commandBuffer: commandBuffer,
        scene: scene,
        context: self,
      )
    }

    commandBuffer.present(renderDescriptor.currentDrawable)
    commandBuffer.commit()
  }

  func updateLighting(scene: RNDRScene) {
    let lights = scene.lights

    sunLights = lights.filter { $0.type == .Sun }.map {
      SHDRLight(
        type: LightType(UInt32($0.type.rawValue)),
        position: $0.position,
        color: $0.color,
        specularColor: $0.specularColor,
        radius: $0.radius,
        attenuation: $0.attenuation,
        coneAngle: $0.coneAngle,
        coneDirection: $0.coneDirection,
        coneAttenutation: $0.coneAttenuation
      )
    }
    sunLightBuffer = device.makeBuffer(
      bytes: &sunLights,
      length: MemoryLayout<SHDRLight>.stride * sunLights.count,
      options: []
    )

    pointLights = lights.filter { $0.type == .Point }.map {
      SHDRLight(
        type: LightType(UInt32($0.type.rawValue)),
        position: $0.position,
        color: $0.color,
        specularColor: $0.specularColor,
        radius: $0.radius,
        attenuation: $0.attenuation,
        coneAngle: $0.coneAngle,
        coneDirection: $0.coneDirection,
        coneAttenutation: $0.coneAttenuation
      )
    }
    if pointLights.isNotEmpty {
      pointLightBuffer = device.makeBuffer(
        bytes: &pointLights,
        length: MemoryLayout<SHDRLight>.stride * pointLights.count,
        options: []
      )
    }
  }
}
