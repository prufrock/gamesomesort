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
        onWakeActions?.wakeUp(
          id: id,
          ecs: ecs,
          worldCfg: context.config.world
        )
      case .levelStarted:
        let id = ecs.createEntity("playerTurnStarted")
        ecs.addComponent(id, LECSPEvent(event: .levelStarted))
        // displayCommandsForActiveDolls
      case .playerTurnEnded:
        let id = ecs.createEntity("playerTurnStarted")
        ecs.addComponent(id, LECSPEvent(event: .levelStarted))
      case .playerTurnStarted:
        break
      case .touched(let id):
        let onTap = ecs.getComponent(
          id.id,
          LECSPHUD.Button.OnTap.self
        )
        if let onTap {
          if onTap.list.contains("exit") {
            gameCommands.enqueue(.start(level: 0))
          } else if onTap.list.contains("reload") {
            gameCommands.enqueue(.startWorld(world: "world001"))
          } else if onTap.list.contains("moveUp") {
            print("move the player")
            var playerIds: [LECSId] = []
            ecs.select([LECSId.self, LECSPModel.self]) { row, columns in
              let id = row.component(at: 0, columns, LECSId.self)
              let model = row.component(at: 1, columns, LECSPModel.self)

              if model.name.contains("golem") {
                playerIds.append(id)
              }
            }
            playerIds.forEach { playerId in
              let oPos = ecs.getComponent(playerId.id, LECSPPosition3d.self)!
              let nPos = oPos + [0.0, -1.0, 0.0]
              ecs.addComponent(playerId.id, nPos)
            }
          } else if onTap.list.contains("moveDown") {
            print("move the player")
            var playerIds: [LECSId] = []
            ecs.select([LECSId.self, LECSPModel.self]) { row, columns in
              let id = row.component(at: 0, columns, LECSId.self)
              let model = row.component(at: 1, columns, LECSPModel.self)

              if model.name.contains("golem") {
                playerIds.append(id)
              }
            }
            playerIds.forEach { playerId in
              let oPos = ecs.getComponent(playerId.id, LECSPPosition3d.self)!
              let nPos = oPos + [0.0, 1.0, 0.0]
              ecs.addComponent(playerId.id, nPos)
            }
          } else if onTap.list.contains("moveLeft") {
            print("move the player")
            var playerIds: [LECSId] = []
            ecs.select([LECSId.self, LECSPModel.self]) { row, columns in
              let id = row.component(at: 0, columns, LECSId.self)
              let model = row.component(at: 1, columns, LECSPModel.self)

              if model.name.contains("golem") {
                playerIds.append(id)
              }
            }
            playerIds.forEach { playerId in
              let oPos = ecs.getComponent(playerId.id, LECSPPosition3d.self)!
              let nPos = oPos + [-1.0, 0.0, 0.0]
              ecs.addComponent(playerId.id, nPos)
            }
          } else if onTap.list.contains("moveRight") {
              print("move the player")
              var playerIds: [LECSId] = []
              ecs.select([LECSId.self, LECSPModel.self]) { row, columns in
                let id = row.component(at: 0, columns, LECSId.self)
                let model = row.component(at: 1, columns, LECSPModel.self)

                if model.name.contains("golem") {
                  playerIds.append(id)
                }
              }
              playerIds.forEach { playerId in
                let oPos = ecs.getComponent(playerId.id, LECSPPosition3d.self)!
                let nPos = oPos + [1.0, 0.0, 0.0]
                ecs.addComponent(playerId.id, nPos)
              }
          } else {
            print("The button \(id) has no known onTaps: \(onTap.list)")
          }
        }
      }
    }

    return gameCommands
  }
}
