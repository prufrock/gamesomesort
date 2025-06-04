//
//  ClearColorRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import MetalKit

@MainActor
class RNDRClearColorRenderer: NSObject, RNDRRenderer {
  var device: MTLDevice!
  var commandQueue: MTLCommandQueue!
  var library: MTLLibrary!
  var viewColorPixelFormat: MTLPixelFormat!

  init(metalView: MTKView) {
    guard
      let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue()
    else {
      fatalError("GPU not available")
    }
    self.device = device
    self.commandQueue = commandQueue
    metalView.device = device

    let library = device.makeDefaultLibrary()
    self.library = library
    self.viewColorPixelFormat = metalView.colorPixelFormat

    super.init()
    metalView.clearColor = MTLClearColor(
      red: 0.93,
      green: 0.97,
      blue: 1.0,
      alpha: 1.0
    )
  }

  func resize(view: MTKView, size: CGSize) {
  }

  func render(to view: MTKView) {
    guard
      let commandBuffer = self.commandQueue.makeCommandBuffer(),
      let _ = view.currentRenderPassDescriptor
    else {
      return
    }

    guard let drawable = view.currentDrawable else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
