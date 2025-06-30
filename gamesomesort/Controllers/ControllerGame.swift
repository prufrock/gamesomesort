//
//  GameController.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import MetalKit
import Combine

@MainActor
class ControllerGame: NSObject {
  private let appCore: AppCore
  private var fps: Double = 0

  private var lastFrameTime = CACurrentMediaTime()

  private(set) var game: GMGame?
  private var tapLocation: CGPoint = .zero

  private let controllerInput: ControllerInput

  // Going to run on the main actor for now, because I am not super concerned about multiple threads right. This is
  // setting up the primary controller anyway.
  init(
    appCore: AppCore,
    controllerInput: ControllerInput,
    metalView: MTKView
  ) {
    self.appCore = appCore
    self.controllerInput = controllerInput
    super.init()

    metalView.delegate = self
    fps = Double(metalView.preferredFramesPerSecond)
    mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
  }

  private func bootGame(view: MTKView) {
    guard game == nil else { return }

    game = appCore.createGMGame()
    game?.update(size: view.drawableSize)
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

  func updateTapLocation(_ location: CGPoint) {
    controllerInput.updateTapLocation(location)
  }

  func updateFrameSize(_ size: CGSize) {
    controllerInput.updateFrameSize(size)
  }
}

extension ControllerGame: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    print("GameController:mtkView(drawableSizeWillChange: size: \(size)")
    game?.update(size: size)
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
      let input = controllerInput.update()
      game?.update(timeStep: timeStep, input: input)
    }

    appCore.sync(
      RenderCommand(
        renderDescriptor: createRenderDescriptor(view: view),
        ecs: game!.world.ecs
      )
    )
  }
}
