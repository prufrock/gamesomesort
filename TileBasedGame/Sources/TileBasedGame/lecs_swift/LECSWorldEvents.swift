//
//  LECSWorldEvents.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/13/26.
//

import DataStructures
import LECSPieces
import lecs_swift

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
        let player = createEntity("player-\(id)")
        addComponent(player, LECSPPlayer())
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
