//
//  GameController.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import MetalKit

class GameController: NSObject {
  let appCore: AppCore
  var fps: Double = 0
  var renderer: RNDRClearColorRenderer
  init(appCore: AppCore, metalView: MTKView) {
    self.appCore = appCore
    renderer = RNDRClearColorRenderer(metalView: metalView)
    super.init()
    metalView.delegate = self
    fps = Double(metalView.preferredFramesPerSecond)
    mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
  }
}

extension GameController: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    renderer.render(to: view)
  }

  func draw(in view: MTKView) {
    appCore.sync(
      RenderCommand(metalView: view)
    )
  }
}
