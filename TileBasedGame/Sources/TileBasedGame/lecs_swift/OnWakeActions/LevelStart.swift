//
//  LevelStart.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 6/28/26.
//

import LECSPieces

import GameConfiguration
import LECSPieces
import lecs_swift

extension LECSPOnWake {
  static func levelStart(
    ecs: LECSWorld
  ) {
    let id = ecs.createEntity("levelStarted")
    ecs.addComponent(id, LECSPEvent(event: .levelStarted))
  }
}
