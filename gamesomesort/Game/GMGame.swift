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
  private var selectedLevel: Int? = nil

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

    if selectedLevel == nil {
      initWorld(worldNumber: appCore.config.game.world.initialLevel)
    }

    // reset frequently, just for testing
    if elapsedTime < appCore.config.game.timeLimit {
      var commands = world.update(timeStep: timeStep, input: input)
      elapsedTime += timeStep
      if !commands.isEmpty {
        if case let .start(level) = commands.dequeue() {
          if selectedLevel != level {
            initWorld(worldNumber: level)
          }
        }
      }
    } else {
      initWorld(worldNumber: selectedLevel ?? appCore.config.game.world.initialLevel)
      elapsedTime = 0
    }
  }

  private func initWorld(worldNumber: Int) {
    selectedLevel = worldNumber
    world = appCore.createWorldFactory().create(level: worldNumber, levels: levels)
    world.update(screenDimensions)
    appCore.sync(
      SVCCommandRender.ChangeWorld(
        worldBasis: world.basis,
        worldUprightTransforms: world.uprightTransforms
      )
    )
  }

  func update(_ dimensions: ScreenDimensions) {
    self.screenDimensions = dimensions
    world.update(dimensions)
  }
}
