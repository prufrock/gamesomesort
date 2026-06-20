//
//  CreatesMoveBtns.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 6/19/26.
//

import GameConfiguration
import LECSPieces
import lecs_swift

extension LECSPOnWake {
  static func createsMoveButtons(
    id: LECSId,
    buttons: [GCFGThing],
    ecs: LECSWorld
  ) {
    let sourceEntityPosition = ecs.getComponent(id.id, LECSPPosition3d.self)!
    for button in buttons {
      ecs.createThing(
        from: button,
        at: sourceEntityPosition,
        name: "thing-\(button.type)"
      )
    }
  }
}
