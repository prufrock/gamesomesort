//
//  LECSWorldEvents.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/13/26.
//

import DataStructures
import LECSPieces
import lecs_swift

typealias GameCommands = DSQueueArray<TBDGWorld.Commands>

extension LECSWorld {
  func createEvent(name: String, type: LECSPEvent.EventType) {
    let id = createEntity(name)
    addComponent(id, LECSPEvent(event: type))
  }
}

extension LECSWorld {
  func processEvents() -> GameCommands {
    var gameCommands = GameCommands ()
    select([LECSId.self, LECSPEvent.self]) { row, columns in
      var i = 0
      let counter: () -> Int = { defer {i += 1}; return i }

      let id = row.component(at: counter(), columns, LECSId.self)
      let event = row.component(at: counter(), columns, LECSPEvent.self)
      deleteEntity(id.id)

      switch event.event {
      case .none:
        break
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
