//
//  GameController.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import MetalKit

@MainActor
class GameController: NSObject {
  private let appCore: AppCore
  private var fps: Double = 0

  private var lastFrameTime = CACurrentMediaTime()

  private var game: GMGame?

  // Going to run on the main actor for now, because I am not super concerned about multiple threads right. This is
  // setting up the primary controller anyway.
  init(appCore: AppCore, metalView: MTKView) {
    self.appCore = appCore
    super.init()

    metalView.delegate = self
    fps = Double(metalView.preferredFramesPerSecond)
    mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
  }

  private func bootGame(view: MTKView) {
    guard game == nil else { return }

    game = appCore.createGMGame()
  }

  // Moved this into the GameController, so the renderers don't have to be main actor isolated.
  private func createRenderDescriptor(view: MTKView) -> RenderDescriptor {
    view.device = MTLCreateSystemDefaultDevice()
    view.clearColor = appCore.config.services.renderService.mtlClearColor

    guard let descriptor = view.currentRenderPassDescriptor else {
      fatalError(
        """
        Dang it, couldn't get a currentRenderPassDescriptor.
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

    return RenderDescriptor(
      view: view,
      currentRenderPassDescriptor: descriptor,
      currentDrawable: drawable
    )
  }
}

extension GameController: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    print("GameController:mtkView(drawableSizeWillChange: size: \(size)")
    appCore.sync(ResizeCommand(size: size))
  }

  func draw(in view: MTKView) {
    bootGame(view: view)

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

    appCore.sync(
      RenderCommand(renderDescriptor: createRenderDescriptor(view: view))
    )
  }
}
