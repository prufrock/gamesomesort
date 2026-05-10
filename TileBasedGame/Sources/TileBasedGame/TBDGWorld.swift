//
//  TBDGWorld.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 4/16/26.
//

import DataStructures
import lecs_swift
import Foundation
import GameConfiguration
import VRTMath
import LECSPieces

public let E_NAME_CAMERA_PLAYER = "playerCamera"
public let E_NAME_TAP_LOCATION = "tapLocation"

public class TBDGWorld {
  public let ecs: LECSWorld
  fileprivate let worldConfig: GCFGWorld
  fileprivate let levelConfig: GCFGLevel
  private var screenDimensions = VRTMScreenDimensions(pixelSize: CGSize(), scaleFactor: 1.0)

  public init(
    worldConfig: GCFGWorld,
    levelConfig: GCFGLevel,
    ecs: LECSWorld
  ) {
    self.ecs = ecs
    self.worldConfig = worldConfig
    self.levelConfig = levelConfig
  }

  public func restart() {
    let lvlInit = TBDGLevelInitializer(world: self, level: "")
    lvlInit.reset()
  }

  public func update(_ dimensions: VRTMScreenDimensions) {
    let activeCamera = ecs.entity(E_NAME_CAMERA_PLAYER)!
    self.screenDimensions = dimensions

    ecs.addComponent(
      activeCamera,
      LECSPAspect(aspect: dimensions.aspectRatio)
    )
  }

  public func update(
    timeStep: Float,
    input: TBDGame.Input
  ) -> any DSQueue<TBDGWorld.Commands> {
    let activeCamera = ecs.vrtmCameraPerspective(E_NAME_CAMERA_PLAYER)!
    var gameCommands = DSQueueArray<TBDGWorld.Commands>()

    var inputEvents = input.events
    while !inputEvents.isEmpty {
      let event = inputEvents.dequeue()!
      switch event {
      case .tap(tapLocation: let loc, lastTapTime: _):
        let worldLocation = TBDGTapLocation(
          location: loc
        ).screenToWorldOnZPlane(
          screenDimensions: screenDimensions,
          targetZPlaneWorldCoord: 1,
          camera: activeCamera,
        )!

        var tap = ecs.getTap(name: E_NAME_TAP_LOCATION)
        tap.set(position: worldLocation)
        tap.show()

        ecs.selectTappables { behaviors, position, radius in
          let rectangle = VRTM2D.Rectangle(
            position: position.position.xy,
            radius: radius.radius
          )

          let tapped = rectangle.contains(tap.position.xy)

          if tapped && behaviors.list.contains("exit") {
            print("exit")
            gameCommands.enqueue(.start(level: 0))
          }
          if tapped && behaviors.list.contains("reload") {
            print("exit")
            gameCommands.enqueue(.startWorld(world: "world001"))
          }
        }

      case .screenSizeChanged:
        break
      }
    }
    return gameCommands
  }
}

fileprivate struct TBDGLevelInitializer {
  let world: TBDGWorld
  let level: String

  func reset() {
    initExitButton()
    initPlayerCamera()
    initPointLight()
    initSun()
    initTapLocation()
  }

  private func initPlayerCamera() {
    let cfg = world.levelConfig.playerCamera
    let ecs = world.ecs
    let playerCamera = ecs.createEntity(E_NAME_CAMERA_PLAYER)
    ecs.addComponent(
      playerCamera,
      LECSPCameraFirstPerson(
        fov: cfg.viewAngleDegrees * DEG2RAD,
        nearPlane: cfg.nearPlane,
        farPlane: cfg.farPlane
      )
    )
    ecs.addComponent(playerCamera, LECSPAspect(aspect: 1.0))
    ecs.addComponent(playerCamera, LECSPPosition3d(cfg.position))
    let worldVector: F3 = world.worldConfig.worldVector
    ecs.addComponent(playerCamera, LECSPScale3d(worldVector))
  }

  private func initSun() {
    //TODO: Get the sun in the config
    let cfg = world.levelConfig.sun
    let ecs = world.ecs
    let id = ecs.createEntity("sun")
    var sun = LECSPLight()
    sun.type = .Sun
    let color = LECSPColor(cfg.color)
    let position = LECSPPosition3d(cfg.position)
    ecs.addComponent(id, sun)
    ecs.addComponent(id, color)
    ecs.addComponent(id, position)
  }

  private func initExitButton() {
    let cfg = world.worldConfig.hud.buttons
    cfg.forEach { button in
      let ecs = world.ecs
      let entity = ecs.createEntity(button.name)
      ecs.addComponent(
        entity, LECSPHUD.Button.Behaviors(Set(button.behaviors))
      )
      ecs.addComponent(entity, LECSPPosition3d(button.position))
      ecs.addComponent(entity, LECSPScale3d(F3(repeating: 0.5)))
      ecs.addComponent(entity, LECSPColor(button.color))
      ecs.addComponent(
        entity,
        LECSPQuaternion(Float4x4.rotateY(button.rotationDegrees).q)
      )
      ecs.addComponent(entity, LECSPRadius(button.radius))
      ecs.addComponent(entity, LECSPModel(button.model))
      if button.tappable {
        ecs.addComponent(entity, LECSPTag.Tappable())
      }
      if button.visible {
        ecs.addComponent(entity, LECSPTag.Visible())
      }
    }
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

  private func initTapLocation() {
    let ecs = world.ecs
    let id = ecs.createEntity("tapLocation")
    let position = LECSPPosition3d(-10000, -10000, -10000)
    let radius = LECSPRadius(0)
    ecs.addComponent(id, position)
    ecs.addComponent(id, radius)
    ecs.addComponent(id, LECSPTag.Tap())
  }
}
