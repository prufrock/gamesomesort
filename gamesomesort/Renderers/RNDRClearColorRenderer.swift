//
//  ClearColorRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import MetalKit

class RNDRClearColorRenderer: NSObject, RNDRRenderer {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var library: MTLLibrary!
  static var viewColorPixelFormat: MTLPixelFormat!

  init(metalView: MTKView) {
    guard
      let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue()
    else {
      fatalError("GPU not available")
    }
    Self.device = device
    Self.commandQueue = commandQueue
    metalView.device = device

    let library = device.makeDefaultLibrary()
    Self.library = library
    Self.viewColorPixelFormat = metalView.colorPixelFormat

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
      let commandBuffer = Self.commandQueue.makeCommandBuffer(),
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
