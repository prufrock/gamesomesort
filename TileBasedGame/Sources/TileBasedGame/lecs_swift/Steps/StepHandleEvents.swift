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
        var playerHealth: [Int?] = [nil, nil]
        if let lastLevelData = context.input.lastLevelData as? LevelHandOff {
          playerHealth = [lastLevelData.playerOneHp, lastLevelData.playerTwoHp]
        }

        let playerCount = 0
        ecs.select([LECSId.self, LECSPPlayer.self, LECSPCard.self]) { row, columns in
          let c = counter()
          let id = row.component(at: c(), columns, LECSId.self)
          let _ = row.component(at: c(), columns, LECSPPlayer.self)
          var playerCard = row.component(at: c(), columns, LECSPCard.self)
          let currentPlayerHealth = (playerHealth[playerCount] ?? playerCard.hitPointsTotal)
          playerCard.hitPoints = currentPlayerHealth
          ecs.addComponent(id.id, playerCard)

          let hpCfg = context.config.world.hud.buttons[2]
          let hpButtonsTotal = playerCard.hitPointsTotal
          for hpButton in 0...(hpButtonsTotal - 1) {
            print("sl playerHealth \(playerCard.hitPoints)")
            let color = hpButton >= playerCard.hitPoints ? [0,0,0] : hpCfg.color

            ecs.createTappable(
            color: color,
            model: hpCfg.model,
            name: "hp" + String(format: "%03d", (hpButton + playerCount * 100)),
            onTap: hpCfg.onTap,
            position: hpCfg.position + ([0.6 * hpButton.f, playerCount.f, 0]),
            radius: hpCfg.radius,
            rotationDegY: hpCfg.rotationDegrees,
            scale: hpCfg.radius,
            tappable: hpCfg.tappable,
            visible: true
            )
          }

          let currentHealth = playerHealth[playerCount]
        }

      case .playerTurnEnded:
        print("playerTurnEnded")
        // start monster things
        // select the entities to filter to non-player creatures
        // it's a creature because it has a card, eventually players will have cards, maybe...
        ecs.select([LECSId.self, LECSPCard.self, LECSPPosition3d.self]) { row, columns in
          let count = counter()
          let id = row.component(at: count(), columns, LECSId.self)
          var card = row.component(at: count(), columns, LECSPCard.self)
          let position = row.component(at: count(), columns, LECSPPosition3d.self)

          var spentTurn = false
          // make sure it's not a player
          if ecs.getComponent(id.id, LECSPPlayer.self) == nil {
            // look for something to attack, eventually behavior controlled
            let directions: [F3] = [[1,0,0],[-1,0,0],[0,1,0],[0,-1,0]]
            directions.forEach { direction in
              // check to see if it's a player
              if let possiblePlayerId = ecs.findEntity(at: position.position + direction, type: .creature),
                 let player = ecs.getComponent(possiblePlayerId.id, LECSPPlayer.self),
                 var playerCard = ecs.getComponent(possiblePlayerId.id, LECSPCard.self){
                // attack the player, using scale for now...
                spentTurn = true
                // don't attack a player who just moved, so they can move in and strike
                if !player.moved {
                  playerCard.hitPoints = playerCard.hitPoints - 1
                  ecs.addComponent(possiblePlayerId.id, playerCard)
                  print("attacked player: \(possiblePlayerId.id)")
                  // update the players visible hp, is this an event thing or like rendering thing somehow?
                  for hpButtonNumber in 0...(playerCard.hitPointsTotal - 1) {
                    let hpButtonId = ecs.entity("hp" + String(format: "%03d", hpButtonNumber))!
                    if (hpButtonNumber + 1) > playerCard.hitPoints {
                      ecs.addComponent(hpButtonId, LECSPColor([0,0,0]))
                    }
                  }
                }
                // game over if it reaches 0
                if playerCard.hitPoints <= 0 {
                  print("GAME OVER")
                  gameCommands.enqueue(
                    .startWorld(
                      world: context.config.world.name,
                      level: context.config.world.levels[context.config.level.name]?.path ?? "",
                      data: nil
                    )
                  )
                } else {
                  print("player[\(possiblePlayerId)] hp: \(playerCard.hitPoints)")
                }
              }
            }
          }
          // move if the turn hasn't been spent
          let movement = card.movement
          if !spentTurn && movement.path.isNotEmpty {

            var newDirection = movement.direction
            var newPath = movement.path
            var newStep = movement.step
            if movement.step >= movement.path.count {
              newDirection *= -1
              newStep = 0
            }
            if newDirection == -1 {
              newPath = movement.path.reversed()
            }

            let newPosition = position + (newPath[newStep] * F3(repeating: Float(newDirection)))
            ecs.addComponent(id.id, newPosition)
            card.movement = LECSPCard.Movement(
              direction: newDirection,
              step: newStep + 1,
              path: movement.path
            )
            ecs.addComponent(id.id, card)
            spentTurn = true
          }
        }
        // end monster things
        let id = ecs.createEntity("playerTurnStarted")
        ecs.addComponent(id, LECSPEvent(event: .playerTurnStarted))
        var players: [(LECSId, LECSPPlayer)] = []
        //TODO: consider adhoc updates/systems.
        ecs.select([LECSId.self, LECSPPlayer.self]) { rows, columns in
          let count = counter()
          let id = rows.component(at: count(), columns, LECSId.self)
          let player = rows.component(at: count(), columns, LECSPPlayer.self)
          players.append((id, player))
        }
        players.forEach { (playerId, player) in
          ecs.addComponent(
            playerId.id, LECSPPlayer(order: player.order, moved: false, completedTurn: false)
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
          if player.completedTurn == false {
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
                  // check to see if there's a creature there.
                  var entityId = ecs.findEntity(at: position, type: .creature)
                  if entityId != nil {
                    let attackButtonCfgId = 7
                    positionAdjustment = btnCfg.position
                    btnCfg = context.config.world[thing: attackButtonCfgId]!
                    buttonTargetType = .creature
                  } else {
                    entityId = ecs.findEntity(at: position, type: .tile)
                  }
                  if let entityId {
                    let actionButton = ecs.createThing(
                      from: btnCfg,
                      at: sourceEntityPosition + positionAdjustment,
                      name: "thing-\(btnCfg.type)"
                    )
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

                // mark the player completedTurn
                ecs.addComponent(
                  sourcePlayer.owner.id,
                  LECSPPlayer(order: 1, moved: false, completedTurn: true)
                )
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
                var playersCompletedTurns = 0
                var playerCount = 0
                ecs.select([LECSPPlayer.self]) { row, columns in
                  let player = row.component(at: 0, columns, LECSPPlayer.self)
                  playerCount += 1
                  if player.completedTurn {
                    playersCompletedTurns += 1
                  }
                }
                if playersCompletedTurns == playerCount {
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
                level: context.config.level.name,
                data: ecs.storeDataForNextLevel()
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
                      level: levelId,
                      data: ecs.storeDataForNextLevel()
                    )
                  )
                case .pass:
                  break
                }
              }

              ecs.addComponent(playerId.id, nPos)

              ecs.addComponent(playerId.id, LECSPPlayer(order: 1, moved: true, completedTurn: true))
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
            var playersCompletedTurns = 0
            var playerCount = 0
            ecs.select([LECSPPlayer.self]) { row, columns in
              let player = row.component(at: 0, columns, LECSPPlayer.self)
              playerCount += 1
              if player.completedTurn {
                playersCompletedTurns += 1
              }
            }
            if playersCompletedTurns == playerCount {
              let id = ecs.createEntity("playerTurnEnded")
              ecs.addComponent(id, LECSPEvent(event: .playerTurnEnded))
            }
          case .moveConstant(velocity: let velocity):
            print("move with velocity \(velocity)")
            ecs.addComponent(id.id, LECSPVelocity3d(velocity))
          case .wait:
            print("wait")
            if var player = ecs.getComponent(id.id, LECSPPlayer.self) {
              player.completedTurn = true
              ecs.addComponent(id.id, player)
            }
            // check for all out of moves, but should be handled by an event
            var playersCompletedTurns = 0
            var playerCount = 0
            ecs.select([LECSPPlayer.self]) { row, columns in
              let player = row.component(at: 0, columns, LECSPPlayer.self)
              playerCount += 1
              if player.completedTurn {
                playersCompletedTurns += 1
              }
            }
            // delete this dolls buttons
            ecs.select(
              [LECSId.self, LECSPPlayerOwner.self, LECSPTag.GroupA.self]
            ) { rows, components in
              let count =  counter()
              let btnId = rows.component(at: count(), components, LECSId.self)
              let btnPlayer = rows.component(at: count(), components, LECSPPlayerOwner.self)
              if btnPlayer.owner == id {
                ecs.deleteEntity(btnId.id)
              }
            }
            if playersCompletedTurns == playerCount {
              let id = ecs.entity("playerTurnEnded") ?? ecs.createEntity("playerTurnEnded")
              ecs.addComponent(id, LECSPEvent(event: .playerTurnEnded))
            }
          }
        }
      }
    }

    return gameCommands
  }
}

extension LECSWorld {
  func storeDataForNextLevel() -> LevelHandOff {
    // not worrying too much about the order right now
    var playerHp: [Int:Int] = [:]
    var playerCount: Int = 0
    select([LECSPCard.self, LECSPPlayer.self]) { row, columns in
      let c = counter()
      let card = row.component(at: c(), columns, LECSPCard.self)

      playerHp[playerCount] = card.hitPoints
      playerCount += 1
    }

    return LevelHandOff(playerOneHp: playerHp[0] ?? 1, playerTwoHp: playerHp[1] ?? 1)
  }
}

struct LevelHandOff {
  let playerOneHp: Int
  let playerTwoHp: Int
}
