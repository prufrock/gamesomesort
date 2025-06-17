//
//  World.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

import lecs_swift

class GMWorld {
  private let config: AppCoreConfig
  public let ecs: LECSWorld
  private(set) var map: GMTileMap

  init(config: AppCoreConfig, ecs: LECSWorld, map: GMTileMap) {
    self.config = config
    self.ecs = ecs
    self.map = map
  }

  /// Update the game.
  /// - Parameters:
  ///   - timeStep: The amount of time to move it forward.
  func update(timeStep: Float) {
    //print("world updated: \(timeStep)")
  }
}
