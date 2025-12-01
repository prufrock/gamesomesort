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
  var world: any GMWorld
  private let levels: [GMTileMap]
  private let appCore: AppCore
  private var screenDimensions = ScreenDimensions(pixelSize: CGSize(), scaleFactor: 1.0)
  private var elapsedTime: Float = 0
  private var selectedLevel: Int

  init(appCore: AppCore, levels: [GMTileMap]) {
    self.appCore = appCore
    self.levels = levels
    world = appCore.createWorldFactory().create(
      level: appCore.config.game.world.initialLevel,
      levels: levels
    )
    selectedLevel = appCore.config.game.world.initialLevel
  }

  /// Update the game.
  /// - Parameters:
  ///   - timeStep: The amount of time to move forward.
  func update(timeStep: Float, input: GMGameInput) {

    // reset frequently, just for testing
    if elapsedTime < appCore.config.game.timeLimit {
      var commands = world.update(timeStep: timeStep, input: input)
      elapsedTime += timeStep
      if !commands.isEmpty {
        if case let .start(level) = commands.dequeue() {
          if selectedLevel != level {
            selectedLevel = level
            world = appCore.createWorldFactory().create(level: selectedLevel, levels: levels)
            world.update(screenDimensions)
          }
        }
      }
    } else {
      world = appCore.createWorldFactory().create(level: selectedLevel, levels: levels)
      world.update(screenDimensions)
      elapsedTime = 0
    }
  }

  func update(_ dimensions: ScreenDimensions) {
    self.screenDimensions = dimensions
    world.update(dimensions)
  }
}
