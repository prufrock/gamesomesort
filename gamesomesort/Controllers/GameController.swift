//
//  GameController.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import MetalKit

class GameController: NSObject {
  var fps: Double = 0
  var renderer: ClearColorRenderer
  init(metalView: MTKView) {
    renderer = ClearColorRenderer(metalView: metalView)
    super.init()
    metalView.delegate = self
    fps = Double(metalView.preferredFramesPerSecond)
    mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
  }
}

extension GameController: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    renderer.mtkView(view, drawableSizeWillChange: size)
  }

  func draw(in view: MTKView) {
    renderer.draw(in: view)
  }
}
