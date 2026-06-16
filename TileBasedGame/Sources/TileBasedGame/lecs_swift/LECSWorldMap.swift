//
//  LECSWorldMap.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/17/26.
//

import GameConfiguration
import LECSPieces
import lecs_swift
import VRTMath

extension LECSWorld {
  func createTile(
    color: VRTMColorA,
    model: String,
    position: F3,
    radius: Float,
    rotationDegY: Float,
    scale: Float,
    tappable: Bool,
    visible: Bool
  ) {
    let tile = createEntity("tile\(position.x)-\(position.y)")
    addComponent(tile, LECSPPosition3d(position))
    addComponent(tile, LECSPRadius(radius))
    addComponent(tile, LECSPColor(color: color))
    addComponent(tile, LECSPScale3d(F3(repeating: scale)))
    addComponent(tile, LECSPQuaternion(Float4x4.rotateY(rotationDegY).q))
    addComponent(tile, LECSPModel(model))
    if visible {
      addComponent(tile, LECSPTag.Visible())
    }
    if tappable {
      addComponent(tile, LECSPTag.Tappable())
      addComponent(tile, LECSPHUD.Button.Behaviors([]))
    }
  }

  @discardableResult
  func createThing(
    from config: GCFGThing,
    at sourcePosition: LECSPPosition3d,
    name: String? = nil
  ) -> LECSEntityId {
    let playerPostion = F3(
      x: sourcePosition.x + config.position.x,
      y: sourcePosition.y + config.position.y,
      z: sourcePosition.z + config.position.z
    )
    return createThing(
      color: config.color.vrtma,
      model: config.model,
      onWake: config.onWake,
      position: playerPostion,
      radius: config.radius,
      rotationDegY: config.rotationDegY,
      scale: config.scale,
      tappable: config.tappable,
      visible: config.visible,
      name: name ?? ""
    )
  }

  @discardableResult
  func createThing(
    color: VRTMColorA,
    model: String,
    onWake: [GCFGOnWakeAction],
    position: F3,
    radius: Float,
    rotationDegY: Float,
    scale: Float,
    tappable: Bool,
    visible: Bool,
    name: String = "thing"
  ) -> LECSEntityId {
    let thing = createEntity("\(name)-\(position.x)-\(position.y)")
    addComponent(thing, LECSPPosition3d(position))
    addComponent(thing, LECSPRadius(radius))
    addComponent(thing, LECSPColor(color: color))
    addComponent(thing, LECSPScale3d(F3(repeating: scale)))
    addComponent(thing, LECSPQuaternion(Float4x4.rotateY(rotationDegY * DEG2RAD).q))
    addComponent(thing, LECSPModel(model))

    if onWake.isNotEmpty {
      addComponent(thing, LECSPTimerSleep())
      let actions: [LECSPOnWake.Action] = onWake.map{ item in
        switch item {
        case .creates(creatureId: let creatureId):
          return LECSPOnWake.Action.creates(creatureId: creatureId)
        case .queuesToPlayer:
          return LECSPOnWake.Action.queuesToPlayer
        case .createsMoveBtns(up: let up, down: let down, left: let left, right: let right):
          return LECSPOnWake.Action.createsMoveBtns(up: up, down: down, left: left, right: right)
        }
      }
      addComponent(thing, LECSPOnWake(Set(actions)))
    }

    if visible {
      addComponent(thing, LECSPTag.Visible())
    }
    if tappable {
      addComponent(thing, LECSPTag.Tappable())
      addComponent(thing, LECSPHUD.Button.Behaviors([]))
    }

    return thing
  }

  @discardableResult
  func createCreature(
    from config: GCFGCreature,
    at sourcePosition: LECSPPosition3d,
    name: String? = nil
  ) -> LECSEntityId {
    let playerPostion = F3(
      x: sourcePosition.x + config.position.x,
      y: sourcePosition.y + config.position.y,
      z: sourcePosition.z + config.position.z
    )
    return createCreature(
      color: config.color.vrtma,
      model: config.model,
      onWake: config.onWake,
      position: playerPostion,
      radius: config.radius,
      rotationDegY: config.rotationDegY,
      scale: config.scale,
      tappable: config.tappable,
      visible: config.visible,
      name: name
    )
  }

  @discardableResult
  func createCreature(
    color: VRTMColorA,
    model: String,
    onWake: [GCFGOnWakeAction],
    position: F3,
    radius: Float,
    rotationDegY: Float,
    scale: Float,
    tappable: Bool,
    visible: Bool,
    name: String? = nil
  ) -> LECSEntityId {
    let thing: LECSEntityId
    if let name {
      thing = createEntity(name)
    } else {
      thing = createEntity("creature-\(position.x)-\(position.y)")
    }
    addComponent(thing, LECSPPosition3d(position))
    addComponent(thing, LECSPRadius(radius))
    addComponent(thing, LECSPColor(color: color))
    addComponent(thing, LECSPScale3d(F3(repeating: scale)))
    addComponent(thing, LECSPQuaternion(Float4x4.rotateY(rotationDegY * DEG2RAD).q))
    addComponent(thing, LECSPModel(model))

    if onWake.isNotEmpty {
      let actions: [LECSPOnWake.Action] = onWake.map{ item in
        switch item {
        case .creates(creatureId: let creatureId):
          return LECSPOnWake.Action.creates(creatureId: creatureId)
        case .queuesToPlayer:
          return LECSPOnWake.Action.queuesToPlayer
        case .createsMoveBtns(up: let up, down: let down, left: let left, right: let right):
          return LECSPOnWake.Action.createsMoveBtns(up: up, down: down, left: left, right: right)
        }
      }
      addComponent(thing, LECSPOnWake(Set(actions)))
      addComponent(thing, LECSPTimerSleep())
    }

    if visible {
      addComponent(thing, LECSPTag.Visible())
    }
    if tappable {
      addComponent(thing, LECSPTag.Tappable())
      addComponent(thing, LECSPHUD.Button.Behaviors([]))
    }

    return thing
  }
}
