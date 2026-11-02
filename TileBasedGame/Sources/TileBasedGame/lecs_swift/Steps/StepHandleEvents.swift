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
              var btnCfg = context.config.world[thing: button]!
              let position = F3(
                x: sourceEntityPosition.x + btnCfg.position.x,
                y: sourceEntityPosition.y + btnCfg.position.y,
                z: sourceEntityPosition.z + btnCfg.position.z
              )

              var buttonTargetType: LECSPEntityType = .tile
              var positionAdjustment: F3 = [0, 0, 0]
              if let tileId = context.config.level[tile: Int(position.x), Int(position.y)] {
                let tileCfg = context.config.world[tile: tileId]!

                if tileCfg.onEnter.isNotEmpty {
                  if let creatureId = context.config.level[creature: Int(position.x), Int(position.y)],
                     let creature = context.config.world[creature: creatureId]
                  {
                    print("creature: \(creature.type)")
                    let attackButtonCfgId = 7
                    positionAdjustment = btnCfg.position
                    btnCfg = context.config.world[thing: attackButtonCfgId]!
                    buttonTargetType = .creature
                  } else {
                    print("actionButton: \(btnCfg.type)")
                  }
                  let actionButton = ecs.createThing(
                    from: btnCfg,
                    at: sourceEntityPosition + positionAdjustment,
                    name: "thing-\(btnCfg.type)"
                  )

                  // gotta find the entities
                  var entityId = LECSId()
                  ecs.select([LECSId.self, LECSPPosition3d.self, LECSPEntity.self]) { row, columns in
                    let foundId = row.component(at: 0, columns, LECSId.self)
                    let foundPosition = row.component(at: 1, columns, LECSPPosition3d.self)
                    let foundEntity = row.component(at: 2, columns, LECSPEntity.self)

                    if foundPosition.x >= position.x && foundPosition.x <= position.x.rounded(.up)
                        && foundPosition.y >= position.y && foundPosition.y <= position.y.rounded(.up)
                        && foundEntity.type == buttonTargetType {
                      entityId = foundId
                    }
                  }
                  ecs.addComponent(
                    actionButton,
                    LECSPPlayerOwner(playerId)
                  )
                  ecs.addComponent(
                    actionButton,
                    LECSPButtonTarget(
                      id: entityId,
                      type: buttonTargetType
                    )
                  )
                  ecs.addComponent(actionButton, LECSPTag.GroupA())
                }
              }
            }
          }
        }
      case .touched(let id):
        let onTap = ecs.getComponent(
          id.id,
          LECSPHUD.Button.OnTap.self
        )
        // Maybe this should be more general?
        onTap?.list.forEach { action in
          switch action {
          case .affectTargetStat(value: let value):
            if let sourcePlayer = ecs.getComponent(id.id, LECSPPlayerOwner.self),
              let buttonTarget = ecs.getComponent(id.id, LECSPButtonTarget.self),
                buttonTarget.type == .creature {
              print("affectTargetStat \(value)")
              if var creatureCard = ecs.getComponent(buttonTarget.id.id, LECSPCard.self) {
                creatureCard.hitPoints += value
                if creatureCard.hitPoints == 0 {
                  ecs.deleteEntity(buttonTarget.id.id)
                } else {
                  ecs.addComponent(buttonTarget.id.id, creatureCard)
                }

                // mark the player as moved
                ecs.addComponent(sourcePlayer.owner.id, LECSPPlayer(order: 1, moved: true))
                // delete this dolls buttons
                ecs.select(
                  [LECSId.self, LECSPPlayerOwner.self, LECSPTag.GroupA.self]
                ) { rows, components in
                  let count =  counter()
                  let id = rows.component(at: count(), components, LECSId.self)
                  let btnPlayer = rows.component(at: count(), components, LECSPPlayerOwner.self)
                  if btnPlayer.owner == sourcePlayer.owner {
                    ecs.deleteEntity(id.id)
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
              }
            }
          case .exit:
            gameCommands.enqueue(.start(level: 0))
          case .reload:
            gameCommands.enqueue(
              .startWorld(
                world: context.config.world.name,
                level: context.config.level.name
              )
            )
          case .move:
            let targetPlayer = ecs.getComponent(id.id, LECSPPlayerOwner.self)!
            print("move the player \(targetPlayer.owner.id) up")
            let player = ecs.getComponent(targetPlayer.owner.id, LECSPPlayer.self)!
            let playerIds: [(LECSId, LECSPPlayer)] = [(targetPlayer.owner, player)]

            playerIds.forEach { (playerId, player) in
              let btnPos = ecs.getComponent(id.id, LECSPPosition3d.self)!
              let oPos = ecs.getComponent(playerId.id, LECSPPosition3d.self)!
              let nPos = oPos + [btnPos.x - oPos.x, btnPos.y - oPos.y, 0.0]
              // check for exit
              let tileId = context.config.level[tile: Int(nPos.x), Int(nPos.y)]!
              let tileCfg = context.config.world[tile: tileId]!

              tileCfg.onEnter.forEach { enterAction in
                switch enterAction {
                case .gotoLevel(let levelId):
                  print("gotoLevel \(levelId)")
                  gameCommands.enqueue(
                    .startWorld(
                      world: context.config.world.name,
                      level: levelId
                    )
                  )
                case .pass:
                  break
                }
              }

              ecs.addComponent(playerId.id, nPos)
              ecs.addComponent(playerId.id, LECSPPlayer(order: 1, moved: true))
              // delete this dolls buttons
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
          case .moveConstant(velocity: let velocity):
            print("move with velocity \(velocity)")
            ecs.addComponent(id.id, LECSPVelocity3d(velocity))
          }
        }
      }
    }

    return gameCommands
  }
}
