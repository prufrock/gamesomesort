//
//  RNDRTileBasedDeferredRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/14/25.
//
import MetalKit
import lecs_swift

class RNDRTileBasedDeferredRenderer: RNDRRenderer {
  private let config: AppCoreConfig
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private let library: MTLLibrary
  private var forwardRenderPass: ForwardRenderPass? = nil

  private var squareRenderer = RNDRSquare()

  private var screenDimensions = ScreenDimensions()

  private let controllerTexture = ControllerTexture()

  // model controller?
  // private let sphere: GEOModel
  private let sphere: GEOModel

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

    sphere = GEOModel(name: "sphere", primitiveType: .sphere, controllerTexture: controllerTexture, device: device)
  }

  func resize(_ dimensions: ScreenDimensions) {
    screenDimensions = dimensions
  }

  func initializePipelines(pixelFormat: MTLPixelFormat) {
    squareRenderer.initPipelines(device: device, library: library, pixelFormat: pixelFormat)
  }

  func initializeRenderPasses(pixelFormat: MTLPixelFormat, depthStencilPixelFormat: MTLPixelFormat) {
    forwardRenderPass = ForwardRenderPass(
      device: device,
      colorPixelFormat: pixelFormat,
      depthPixelFormat: depthStencilPixelFormat,
      library: library
    )
  }

  func createUniforms(_ ecs: LECSWorld) -> SHDRUniforms {
    let camera = ecs.gmCameraFirstPerson("playerCamera")!
    var uniforms = SHDRUniforms()

    uniforms.viewMatrix = camera.viewMatrix
    uniforms.projectionMatrix = camera.projection

    return uniforms
  }

  func createParams(_ ecs: LECSWorld) -> SHDRParams {
    let camera = ecs.gmCameraFirstPerson("playerCamera")!

    var params = SHDRParams()

    params.lightCount = 0
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

    guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor.currentRenderPassDescriptor)
    else {
      fatalError(
        """
        Dang it, couldn't create a command encoder.
        """
      )
    }

    let uniforms = self.createUniforms(ecs)
    let params = self.createParams(ecs)

    squareRenderer.draw(ecs: ecs, encoder: encoder)

    encoder.endEncoding()
    commandBuffer.present(renderDescriptor.currentDrawable)
    commandBuffer.commit()
  }
}
