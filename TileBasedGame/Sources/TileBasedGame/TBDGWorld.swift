//
//  TBDGWorld.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 4/16/26.
//

import lecs_swift
import GameConfiguration

public class TBDGWorld {
  public let ecs: LECSWorld
  private let worldConfig: GCFGWorld

  public init(worldConfig: GCFGWorld, ecs: LECSWorld) {
    self.ecs = ecs
    self.worldConfig = worldConfig
  }
}
