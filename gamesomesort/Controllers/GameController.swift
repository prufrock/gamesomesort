//
//  GameController.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import MetalKit

class GameController: NSObject {
  private let appCore: AppCore
  private var fps: Double = 0
  private let view: MTKView
  private var renderer: RNDRClearColorRenderer

  private var lastFrameTime = CACurrentMediaTime()

  private var game: GMGame?

  init(appCore: AppCore, metalView: MTKView) {
    self.appCore = appCore
    renderer = RNDRClearColorRenderer(metalView: metalView)
    view = metalView
    super.init()

    metalView.delegate = self
    fps = Double(view.preferredFramesPerSecond)
    mtkView(view, drawableSizeWillChange: metalView.drawableSize)
  }

  private func bootGame() {
    guard game == nil else { return }

    let levels: [GMTileMap] = [GMTileMap(GMMapData(tiles: [], width: 0, things: []), index: 0)]

    game = GMGame(config: appCore.config, levels: levels)

    appCore.sync(RenderCommand(metalView: view))
  }
}

extension GameController: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    renderer.render(to: view)
  }

  func draw(in view: MTKView) {
    bootGame()

    game?.update(timeStep: 0)
    appCore.sync(
      RenderCommand(metalView: view)
    )

    // run the clock
    let time = CACurrentMediaTime()
    // the time that has passed since the last frame, if it's longer than the maximumTimeStep just use that. If the
    // elapsed time is greater than the maximum it can mess up collision checks.
    let elapsedTime = min(appCore.config.platform.maximumTimeStep, Float(time - lastFrameTime))
    // The number of steps that fit into the amount of time elapsed.
    let worldSteps = (elapsedTime / appCore.config.platform.worldTimeStep).rounded(.up)
    // The amount of time to move forward per calculation.
    let timeStep = elapsedTime / worldSteps
    for _ in 0..<Int(worldSteps) {
      game?.update(timeStep: timeStep)
    }
  }
}
