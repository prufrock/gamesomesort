//
//  RNDRSquareRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/4/25.
//

import MetalKit

///  At what point does the processing required to load the renderer require putting it behind a loading screen?
class RNDRSquareRenderer: RNDRRenderer {
  private let config: AppCoreConfig
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
//  private let library: MTLLibrary

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

//    guard let newLibrary = device.makeDefaultLibrary() else {
//      fatalError(
//        """
//        What in the what?! The library couldn't be loaded.
//        """
//      )
//    }
//
//    library = newLibrary
  }

  func resize(view: MTKView, size: CGSize) {
    // no-op
  }

  func render(to view: MTKView) {
    view.device = device
    view.clearColor = config.services.renderService.mtlClearColor

    guard let commandBuffer = commandQueue.makeCommandBuffer() else {
      fatalError(
        """
        Ugh, no command buffer. They must be fresh out!
        """
      )
    }

    guard let descriptor = view.currentRenderPassDescriptor, let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
      fatalError(
        """
        Dang it, couldn't create a command encoder.
        """
      )
    }

    guard let drawable = view.currentDrawable else {
      fatalError(
        """
        Wakoom! Attempt to get the view's drawable and everything fell apart! Boo!
        """
      )
    }

    encoder.endEncoding()
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}

extension AppCoreConfig.Services.RenderService {
  var mtlClearColor: MTLClearColor {
    .init(red: clearColor.0, green: clearColor.1, blue: clearColor.2, alpha: clearColor.3)
  }
}
