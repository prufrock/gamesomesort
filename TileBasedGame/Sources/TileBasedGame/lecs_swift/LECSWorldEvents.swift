//
//  LECSWorldEvents.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/13/26.
//

import DataStructures
import LECSPieces
import lecs_swift
import VRTMath

func counter(start:Int = 0) -> () -> Int {
  var i = start
  return { defer {i += 1}; return i }
}

extension LECSWorld {
  func createEvent(name: String, type: LECSPEvent.EventType) {
    let id = createEntity(name)
    addComponent(id, LECSPEvent(event: type))
  }
}

extension LECSWorld {
  func processEvents() -> GameCommands {
    var gameCommands = GameCommands()
    select([LECSId.self, LECSPEvent.self]) { row, columns in
      let c: () -> Int = counter()
      let id = row.component(at: c(), columns, LECSId.self)
      let event = row.component(at: c(), columns, LECSPEvent.self)
      deleteEntity(id.id)

      switch event.event {
      case .none:
        break
      case .awake(let id):
        removeComponent(id.id, component: LECSPTimerSleep.self)
        let sourceEntityPosition = getComponent(id.id, LECSPPosition3d.self)!
        let playerPostion = F3(
          x: sourceEntityPosition.x,
          y: sourceEntityPosition.y,
          z: 0.5
        )
        let creature = createThing(
          color: VRTMColorA(F3(0, 1, 1)),
          model: "square-bella.usdz",
          onWake: [],
          position: playerPostion,
          radius: 0.5,
          rotationDegY: 180,
          scale: 0.5,
          tappable: false,
          visible: true,
          name: "player-01-\(id)"
        )
        addComponent(creature, LECSPPlayer())
      case .touched(let id):
        let behaviors = getComponent(
          id.id,
          LECSPHUD.Button.Behaviors.self
        )
        if let behaviors {
          if behaviors.list.contains("exit") {
            gameCommands.enqueue(.start(level: 0))
          }
          if behaviors.list.contains("reload") {
            gameCommands.enqueue(.startWorld(world: "world001"))
          }
        }
      }
    }

    return gameCommands
  }
}
