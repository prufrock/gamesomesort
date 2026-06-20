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
      switch action {
      case .creates(creatureId: let creatureId):
        print("creates creatureId: \(creatureId)")
        Self.createsCreature(
          id: id,
          creature: worldCfg[creature: Int(creatureId)!]!,
          ecs: ecs
        )
      case .queuesToPlayer:
        print("queuesToPlayer")
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
}
