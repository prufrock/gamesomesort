//
//  CreatesCreature.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 6/19/26.
//

import GameConfiguration
import LECSPieces
import lecs_swift

extension LECSPOnWake {
  static func createsCreature(
    id: LECSId,
    creature: GCFGCreature,
    ecs: LECSWorld
  ) {
    // Create it relative to the thing that created it.
    let sourceEntityPosition = ecs.getComponent(id.id, LECSPPosition3d.self)!
    let creature = ecs.createCreature(
      from: creature,
      at: sourceEntityPosition,
      name: "creature-\(creature.type)-\(id)"
    )
    ecs.addComponent(creature, LECSPPlayer(order: 1, moved: false))
  }
}
