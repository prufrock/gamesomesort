//
//  GMGame.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

import Foundation

/// Game manages all of the logic of the game. The World is a part of Game because there may be time when Game needs to
/// change World or interrupt it. If World wants to change itself, like change levels, or do something to Game it needs to
/// pass a command up.
class GMGame {
  var world: GMWorld
  private let levels: [GMTileMap]
  private let appCore: AppCore
  private var screenDimensions = ScreenDimensions(pixelSize: CGSize(), scaleFactor: 1.0)
  private var elapsedTime: Float = 0

  init(appCore: AppCore, levels: [GMTileMap]) {
    self.appCore = appCore
    self.levels = levels
    world = appCore.createWorldFactory().create(
      level: appCore.config.game.world.initialLevel,
      levels: levels
    )
  }

  /// Update the game.
  /// - Parameters:
  ///   - timeStep: The amount of time to move forward.
  func update(timeStep: Float, input: GMGameInput) {

    // reset frequently, just for testing
    if elapsedTime < appCore.config.game.timeLimit {
      world.update(timeStep: timeStep, input: input)
      elapsedTime += timeStep
    } else {
      world = appCore.createWorldFactory().create(level: 0, levels: levels)
      world.update(screenDimensions)
      elapsedTime = 0
    }
  }

  func update(_ dimensions: ScreenDimensions) {
    self.screenDimensions = dimensions
    world.update(dimensions)
  }
}
