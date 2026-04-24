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

fileprivate struct TBDGLevelInitializer {
  let world: TBDGWorld
  let level: String

  func reset() {
    initPlayerCamera()
    initSun()
    initExitButton()
    initPointLight()
  }

  private func initPlayerCamera() {
    //TODO: get all of this stuff from the config
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

  private func initSun() {
    //TODO: Get the sun in the config
    let cfg = world.levelConfig.playerCamera
    let ecs = world.ecs
    let id = ecs.createEntity("sun")
    var sun = LECSPLight()
    sun.type = .Sun
    let color = LECSPColor([1, 1, 1])
    let position = LECSPPosition3d([0, 0, -1])
    ecs.addComponent(id, sun)
    ecs.addComponent(id, color)
    ecs.addComponent(id, position)
  }

  private func initExitButton() {
    //TODO: get this from the config
    let ecs = world.ecs
    let button = ecs.createEntity("exitButton")
    ecs.addComponent(button, LECSPPosition3d(1.0, -2, 1.0))
    ecs.addComponent(button, LECSPScale3d(F3(repeating: 0.5)))
    ecs.addComponent(button, LECSPColor([1.0, 1.0, 1.0]))
    ecs.addComponent(button, LECSPQuaternion(Float4x4.rotateY(0).q))
    ecs.addComponent(button, LECSPRadius(0.5))
    ecs.addComponent(button, LECSPModel("brick-sphere.usdz"))
//    ecs.addComponent(button, CTTappable())
    ecs.addComponent(button, LECSPTagVisible())
  }

  //TODO: remove later, just to make the renderer happy
  private func initPointLight() {
    let ecs = world.ecs
    var light = LECSPLight()
    light.type = .Point
    light.attenuation = [0.2, 10, 50]
    light.specularColor = F3(repeating: 0.6)
    let color = LECSPColor([0, 0.5, 0.5])
    let position = LECSPPosition3d([6, 3, 2.4])
    let id = ecs.createEntity("pointLight")
    ecs.addComponent(id, light)
    ecs.addComponent(id, color)
    ecs.addComponent(id, position)
  }
}
