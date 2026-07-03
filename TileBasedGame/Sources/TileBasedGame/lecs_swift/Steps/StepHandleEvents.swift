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
        print("levelStarted")
        let id = ecs.createEntity("playerTurnStarted")
        ecs.addComponent(id, LECSPEvent(event: .playerTurnStarted))

      case .playerTurnEnded:
        print("playerTurnEnded")
        let id = ecs.createEntity("playerTurnStarted")
        ecs.addComponent(id, LECSPEvent(event: .playerTurnStarted))
        var players: [(LECSId, LECSPPlayer)] = []
        //TODO: consider adhoc updates/systems.
        ecs.select([LECSId.self, LECSPPlayer.self]) { rows, components in
          let count = counter()
          let id = rows.component(at: count(), components, LECSId.self)
          let player = rows.component(at: count(), components, LECSPPlayer.self)
          players.append((id, player))
        }
        players.forEach { (playerId, player) in
          ecs.addComponent(
            playerId.id, LECSPPlayer(order: player.order, moved: false)
          )
        }
      case .playerTurnStarted:
        print("playerTurnStarted")
        // at the start of a turn
        // displayCommandsForActiveDolls
        ecs.select([LECSId.self, LECSPPlayer.self]) { row, components in
          let count = counter()
          let playerId = row.component(at: count(), components, LECSId.self)
          let player = row.component(at: count(), components, LECSPPlayer.self)
          if player.moved == false {
            let sourceEntityPosition = ecs.getComponent(playerId.id, LECSPPosition3d.self)!
            let buttons: [Int] = [2, 3, 4, 5]
            for button in buttons {
              let thing = context.config.world[thing: button]!
              let moveButton = ecs.createThing(
                from: thing,
                at: sourceEntityPosition,
                name: "thing-\(thing.type)"
              )
              ecs.addComponent(
                moveButton,
                LECSPPlayerOwner(playerId)
              )
              ecs.addComponent(moveButton, LECSPTag.GroupA())
            }
          }
        }
      case .touched(let id):
        let onTap = ecs.getComponent(
          id.id,
          LECSPHUD.Button.OnTap.self
        )
        // Maybe this should be more general?
        if let onTap {
          if onTap.list.contains("exit") {
            gameCommands.enqueue(.start(level: 0))
          } else if onTap.list.contains("reload") {
            gameCommands.enqueue(.startWorld(world: "world001"))
          } else if onTap.list.contains("move") {
            let targetPlayer = ecs.getComponent(id.id, LECSPPlayerOwner.self)!
            print("move the player \(targetPlayer.owner.id) up")
            let player = ecs.getComponent(targetPlayer.owner.id, LECSPPlayer.self)!
            let playerIds: [(LECSId, LECSPPlayer)] = [(targetPlayer.owner, player)]

            playerIds.forEach { (playerId, player) in
              let btnPos = ecs.getComponent(id.id, LECSPPosition3d.self)!
              let oPos = ecs.getComponent(playerId.id, LECSPPosition3d.self)!
              let nPos = oPos + [btnPos.x - oPos.x, btnPos.y - oPos.y, 0.0]
              ecs.addComponent(playerId.id, nPos)
              ecs.addComponent(playerId.id, LECSPPlayer(order: 1, moved: true))
              // delete this dolls move buttons
              ecs.select(
                [LECSId.self, LECSPPlayerOwner.self, LECSPTag.GroupA.self]
              ) { rows, components in
                let count =  counter()
                let id = rows.component(at: count(), components, LECSId.self)
                let btnPlayer = rows.component(at: count(), components, LECSPPlayerOwner.self)
                if btnPlayer.owner == targetPlayer.owner {
                  ecs.deleteEntity(id.id)
                }
              }
            }

            // check for all out of moves, but should be handled by an event
            var playersMoved = 0
            var playerCount = 0
            ecs.select([LECSPPlayer.self]) { row, columns in
              let player = row.component(at: 0, columns, LECSPPlayer.self)
              playerCount += 1
              if player.moved {
                playersMoved += 1
              }
            }
            if playersMoved == playerCount {
              let id = ecs.createEntity("playerTurnEnded")
              ecs.addComponent(id, LECSPEvent(event: .playerTurnEnded))
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
