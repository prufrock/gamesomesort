//
//  OnWakeActions.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 6/19/26.
//

import GameConfiguration
import LECSPieces
import lecs_swift

extension LECSPOnWake {
  func wakeUp(id: LECSId, ecs: LECSWorld, worldCfg: GCFGWorld) {
    set.forEach { action in
      action.execute(sourceId: id, ecs: ecs, worldCfg: worldCfg)
    }
  }
}

extension LECSPOnWake.Action {
  func execute(sourceId id: LECSId, ecs: LECSWorld, worldCfg: GCFGWorld) {
    switch self {
    case .creates(creatureId: let creatureId):
      LECSPOnWake.createsCreature(
        id: id,
        creature: worldCfg[creature: Int(creatureId)!]!,
        ecs: ecs
      )
    case .queuesToPlayer:
      LECSPOnWake.queuesToPlayer()
    case .createsMoveBtns(
      up: let up, down: let down, left: let left, right: let right
    ):
      LECSPOnWake.createsMoveButtons(
        id: id,
        buttons: [
          worldCfg[thing: up]!,
          worldCfg[thing: down]!,
          worldCfg[thing: left]!,
          worldCfg[thing: right]!
        ],
        ecs: ecs
      )
    }
  }
}
