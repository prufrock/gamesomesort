//
//  TBDGWorld.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 4/16/26.
//

import lecs_swift
import GameConfiguration
import VRTMath
import LECSPieces

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

  public func reset() {
    let lvlInit = TBDGLevelInitializer(world: self, level: "")
    lvlInit.reset()
  }
}

struct TBDGLevelInitializer {
  let world: TBDGWorld
  let level: String

  func reset() {
    initPlayerCamera()
  }

  func initPlayerCamera() {
    let cfg = world.levelConfig.playerCamera
    let ecs = world.ecs
    let playerCamera = ecs.createEntity("playerCamera")
    let worldVector: F3 = [1, -1, 1]
    ecs.addComponent(
      playerCamera,
      LECSPCameraFirstPerson(
        fov: cfg.viewAngleDegrees * (.pi / 180),
        nearPlane: 0.1,
        farPlane: 20
      )
    )
    ecs.addComponent(playerCamera, LECSPAspect(aspect: 1.0))
    ecs.addComponent(playerCamera, LECSPPosition3d(F3(3.5, 4, -7.25)))
    ecs.addComponent(playerCamera, LECSPScale3d(worldVector))
  }

  func initSun() {
    let cfg = world.levelConfig.playerCamera
    let ecs = world.ecs
    let playerCamera = ecs.createEntity("sun")
  }
}
