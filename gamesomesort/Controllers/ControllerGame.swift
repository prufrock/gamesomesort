//
//  GameController.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import Combine
import MetalKit
import RenderObjects
import VRTMath

@MainActor
class ControllerGame: NSObject {
  private let appCore: AppCore
  private var fps: Double = 0

  // The last time a the game was updated.
  private var lastFrameTimeUs: UInt64 = 0
  // The amount of time accumulated so far.
  private var accumulatedTime: UInt64 = 0

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
    let dimensions = VRTMScreenDimensions(
      pixelSize: view.drawableSize,
      scaleFactor: appCore.config.platform.scaleFactor
    )
    game?.update(dimensions)
    appCore.sync(SVCCommandRender.InitializePipelines(pixelFormat: view.colorPixelFormat))
    appCore.sync(SVCCommandRender.Resize(screenDimensions: dimensions))
  }

  // Moved this into the GameController, so the renderers don't have to be main actor isolated.
  private func createRenderDescriptor(view: MTKView) -> SVCRenderDescriptor {
    view.device = MTLCreateSystemDefaultDevice()
    view.clearColor = appCore.config.services.renderService.mtlClearColor
    view.depthStencilPixelFormat = appCore.config.services.renderService.depthStencilPixelFormat

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

    return SVCRenderDescriptor(
      view: view,
      currentRenderPassDescriptor: descriptor,
      currentDrawable: drawable
    )
  }

  func updateTapLocation(_ location: CGPoint) {
    controllerInput.updateTapLocation(location)
  }
}

extension ControllerGame: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    let dimensions = VRTMScreenDimensions(
      pixelSize: size,
      scaleFactor: appCore.config.platform.scaleFactor
    )
    game?.update(dimensions)
    appCore.sync(SVCCommandRender.Resize(screenDimensions: dimensions))
  }

  func draw(in view: MTKView) {
    bootGame(view: view)

    // check the time and convert to integer microseconds
    let currentUs = UInt64(CACurrentMediaTime() * 1_000_000)
    // Initialize last frame time.
    if lastFrameTimeUs == 0 { lastFrameTimeUs = currentUs }

    // The time that has passed since the last frame, fall back to the maximum time step
    // to avoid unexpected behavior.
    let elapsedTime = min(
      appCore.config.platform.maxTimeStepUs,
      currentUs - lastFrameTimeUs
    )
    // Now that we have the elapsed time, the currentTime can set the lastFrameTime.
    lastFrameTimeUs = currentUs

    // Fill the bucket with time.
    accumulatedTime += elapsedTime
    // Then empty the bucket, until there aren't any more steps left.
    // This allows the game to know every time update is called the same amount of time has passed: stepDurationUs.
    while accumulatedTime >= appCore.config.platform.stepDurationUs {
      let input = controllerInput.update(timeStep: 0)
      game?.update(timeStep: 0, input: input)
      // Remove the spent time from the bucket.
      accumulatedTime = accumulatedTime - appCore.config.platform.stepDurationUs
    }

    // Only render if there's something to render.
    if let scene = game?.scene {
      appCore.sync(
        SVCCommandRender.Render(
          renderDescriptor: createRenderDescriptor(view: view),
          ecs: game!.world.ecs,
          scene: scene
        )
      )
    }
  }
}
