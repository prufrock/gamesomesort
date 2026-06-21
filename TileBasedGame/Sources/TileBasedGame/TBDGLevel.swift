//
//  TBDGLevel.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/17/26.
//

import DataStructures
import lecs_swift
import Foundation
import GameConfiguration
import VRTMath
import LECSPieces

struct TBDGLevel {
  let world: TBDGWorld
  let level: String

  func reset() {
    initComponents()
    initButtons()
    initPlayerCamera()
    initPointLight()
    initSun()
    initTapLocation()
    initTiles()
    initThings()
  }

  private func initComponents() {
    let ecs = world.ecs
    let componentHolder = ecs.createEntity("componentHolder")

    func ini(_ component: LECSComponent.Type) {
      ecs.addComponent(componentHolder, component.init())
      ecs.removeComponent(componentHolder, component: component)
    }

    ini(LECSPEvent.self)
    ini(LECSPTimerSleep.self)
    ini(LECSPPlayer.self)
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

  private func initButtons() {
    let cfg = world.worldConfig.hud.buttons
    cfg.forEach { button in
      world.ecs.createTappable(
          color: button.color,
          model: button.model,
          name: button.name,
          onTap: button.onTap,
          position: button.position,
          radius: button.radius,
          rotationDegY: button.rotationDegrees,
          scale: 0.5,
          tappable: button.tappable,
          visible: button.visible
        )
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
    ecs.createTap(
      isVisible: true,
      name: "tapLocation",
      position: F3(-10000, -10000, -10000),
      radius: 0.1
    )
  }

  private func initTiles() {
    let ecs = world.ecs
    let map = world.levelConfig.map

    map.forEachLocation { x, y in
      let tileId = map[tile: x, y]
      let tileCfg = world.worldConfig.entities.tiles[tileId]!

      ecs.createTile(
        color: VRTMColorA(tileCfg.color),
        model: tileCfg.model,
        position: F3(x.f, y.f, 0.0) + tileCfg.position,
        radius: tileCfg.radius,
        rotationDegY: tileCfg.rotationDegY,
        scale: tileCfg.scale,
        tappable: tileCfg.tappable,
        visible: tileCfg.visible
      )
    }
  }

  private func initThings() {
    let ecs = world.ecs
    let map = world.levelConfig.map

    map.forEachLocation { x, y in
      let thingId = map[thing: x, y]
      let thingCfg = world.worldConfig.entities.things[thingId]!

      switch thingCfg.type {
      case .nothing:
        break
      case .playerStart:
        ecs.createThing(
          color: VRTMColorA(thingCfg.color),
          model: thingCfg.model,
          onTap: thingCfg.onTap,
          onWake: thingCfg.onWake,
          position: F3(x.f, y.f, 0.0) + thingCfg.position,
          radius: thingCfg.radius,
          rotationDegY: thingCfg.rotationDegY,
          scale: thingCfg.scale,
          tappable: true,
          visible: true
        )
      case .moveUp, .moveDown, .moveLeft, .moveRight:
        break
      }
    }
  }
}
