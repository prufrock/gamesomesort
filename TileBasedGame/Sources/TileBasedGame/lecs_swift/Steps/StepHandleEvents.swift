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
          } else if case .queuesToPlayer = action {
            print("queuesToPlayer")
            let sourceEntityPosition = ecs.getComponent(id.id, LECSPPosition3d.self)!
            let offsets: [F3] = [
              [1, 0, 0],
              [0, 1, 0],
              [0, -1, 0],
              [-1, 0, 0]
            ]
            for offset in offsets {
              let thing: LECSEntityId
              let position: F3 = F3(
                sourceEntityPosition.x + offset.x,
                sourceEntityPosition.y + offset.y,
                sourceEntityPosition.z + offset.z
              )
              thing = ecs.createEntity("movebtn-\(position.x)-\(position.y)")
              ecs.addComponent(thing, LECSPPosition3d(position))
              ecs.addComponent(thing, LECSPRadius(0.5))
              ecs.addComponent(thing, LECSPColor(color: .init(.blue)))
              ecs.addComponent(thing, LECSPScale3d(F3(repeating: 1.0)))
              ecs.addComponent(thing, LECSPQuaternion(Float4x4.rotateY(0 * DEG2RAD).q))
              ecs.addComponent(thing, LECSPModel("button-one"))
              ecs.addComponent(thing, LECSPTag.Visible())
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
