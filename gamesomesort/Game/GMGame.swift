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
  let world: GMWorld
  private let levels: [GMTileMap]
  private let config: AppCoreConfig

  init(config: AppCoreConfig, levels: [GMTileMap], worldFactory: AppCore.GMWorldFactory) {
    self.config = config
    self.levels = levels
    world = worldFactory.create(level: 0, levels: levels)
  }

  /// Update the game.
  /// - Parameters:
  ///   - timeStep: The amount of time to move forward.
  func update(timeStep: Float, input: GMGameInput) {
    world.update(timeStep: timeStep, input: input)
  }

  func update(size: CGSize) {
    world.update(size: size)
  }
}
