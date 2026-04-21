//
//  TBDGWorld.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 4/16/26.
//

import lecs_swift
import GameConfiguration
import VRTMath

public class TBDGWorld {
  public let ecs: LECSWorld
  fileprivate let worldConfig: GCFGWorld
  fileprivate let levelConfig: GCFGLevel

  public init(
    worldConfig: GCFGWorld,
    levelConfig: GCFGLevel,
    ecs: LECSWorld
  ) {
    self.ecs = ecs
    self.worldConfig = worldConfig
    self.levelConfig = levelConfig
  }
}

struct TBDGLevelInitializer {
  let world: TBDGWorld
  let level: String

  func reset() {

  }

  func initPlayerCamera() {
    let cfg = world.levelConfig.playerCamera
    let ecs = world.ecs
    let playerCamera = ecs.createEntity("playerCamera")
  }

  func initSun() {
    let cfg = world.levelConfig.playerCamera
    let ecs = world.ecs
    let playerCamera = ecs.createEntity("sun")
  }
}
