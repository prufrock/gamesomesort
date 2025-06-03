//
//  GMGame.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

/// Game manages all of the logic of the game. The World is a part of Game because there may be time when Game needs to
/// change World or interrupt it. If World wants to change itself, like change levels, or do something to Game it needs to
/// pass a command up.
class GMGame {
  private let world: GMWorld
  private let levels: [GMTileMap]
  private let config: AppCoreConfig

  init(config: AppCoreConfig, levels: [GMTileMap]) {
    self.config = config
    self.levels = levels
    world = GMWorld(config: config, map: levels[0])
  }

  /// Update the game.
  /// - Parameters:
  ///   - timeStep: The amount of time to move forward.
  func update(timeStep: Float) {
    world.update(timeStep: timeStep)
  }
}
