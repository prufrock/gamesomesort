//
//  ClearColorRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import MetalKit
import lecs_swift

class RNDRClearColorRenderer: NSObject, RNDRRenderer {
  private let config: AppCoreConfig
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue

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
  }

  func resize(size: CGSize) {
    // no-op
  }

  func render(ecs: LECSWorld, to renderDescriptor: RenderDescriptor) {

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

    encoder.endEncoding()
    commandBuffer.present(renderDescriptor.currentDrawable)
    commandBuffer.commit()
  }
}
