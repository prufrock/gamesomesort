//
//  StepHandleEvents.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/25/26.
//

import DataStructures
import LECSPieces
import lecs_swift
import VRTMath

extension StepSelector {
  func handleEvents(context: Context) -> GameCommands {
    let ecs = context.ecs
    let worldCfg = context.config.world
    var gameCommands = GameCommands()

    ecs.select([LECSId.self, LECSPEvent.self]) { row, columns in
      let c: () -> Int = counter()
      let id = row.component(at: c(), columns, LECSId.self)
      let event = row.component(at: c(), columns, LECSPEvent.self)
      ecs.deleteEntity(id.id)

      switch event.event {
      case .none:
        break
      case .awake(let id):
        ecs.removeComponent(id.id, component: LECSPTimerSleep.self)
        let onWakeActions = ecs.getComponent(id.id, LECSPOnWake.self)

        onWakeActions?.set.forEach { action in
          if case .creates(creatureId: let creatureId) = action {
            print("create creatureId: \(creatureId)")
            // Create it relative to the thing that created it.
            let sourceEntityPosition = ecs.getComponent(id.id, LECSPPosition3d.self)!
            let creature = ecs.createCreature(
              from: worldCfg[creature: Int(creatureId)!]!,
              at: sourceEntityPosition,
              name: "player-01-\(id)"
            )
            ecs.addComponent(creature, LECSPPlayer())
          } else if case .createsMoveBtns(
            up: let up, down: let down, left: let left, right: let right
          ) = action {
            print("createsMoveBtns")
            let sourceEntityPosition = ecs.getComponent(id.id, LECSPPosition3d.self)!
            let things: [Int] = [up, down, left, right]
            for thing in things {
              ecs.createThing(
                from: worldCfg[thing: thing]!,
                at: sourceEntityPosition,
                name: "moveUp-\(id.id)-\(thing)"
              )
            }
          }
        }
      case .touched(let id):
        let behaviors = ecs.getComponent(
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
