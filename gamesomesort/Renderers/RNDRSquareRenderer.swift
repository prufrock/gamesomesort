//
//  RNDRSquareRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/4/25.
//

import MetalKit
import lecs_swift

///  At what point does the processing required to load the renderer require putting it behind a loading screen?
class RNDRSquareRenderer: RNDRRenderer {
  private let config: AppCoreConfig
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue

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

    squareRenderer.initBuffers(device: device)
  }

  func resize(_ dimensions: ScreenDimensions) {
    screenDimensions = dimensions
  }

  func initializePipelines(pixelFormat: MTLPixelFormat) {
    guard let library = device.makeDefaultLibrary() else {
      fatalError(
        """
        Heckin' A! The library didn't load!
        """
      )
    }

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

extension AppCoreConfig.Services.RenderService {
  var mtlClearColor: MTLClearColor {
    .init(red: clearColor.0, green: clearColor.1, blue: clearColor.2, alpha: clearColor.3)
  }
}
