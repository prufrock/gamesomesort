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
  private let library: MTLLibrary

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

    guard let newLibrary = device.makeDefaultLibrary() else {
      fatalError(
        """
        What in the what?! The library couldn't be loaded.
        """
      )
    }

    library = newLibrary
  }

  func resize(view: MTKView, size: CGSize) {
    // no-op
  }

  func render(to view: MTKView) {
    // no-op
  }
}
