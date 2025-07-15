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

  private var uniforms = SHDRUniforms()
  private var params = SHDRParams()

  private var squareRenderer = RNDRSquare()

  private var screenDimensions = ScreenDimensions()

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
  }

  func resize(_ dimensions: ScreenDimensions) {
    screenDimensions = dimensions
  }

  func initializePipelines(pixelFormat: MTLPixelFormat) {
    squareRenderer.initPipelines(device: device, library: library, pixelFormat: pixelFormat)
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

    squareRenderer.draw(ecs: ecs, encoder: encoder)

    encoder.endEncoding()
    commandBuffer.present(renderDescriptor.currentDrawable)
    commandBuffer.commit()
  }
}
