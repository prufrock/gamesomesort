//
//  StepAwaken.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/30/26.
//

import LECSPieces
import lecs_swift

extension StepSelector {
  /// Emits a wake up event for each entity whose sleep timer is less
  /// than or equal to 0.
  func awaken(context ctx: Context) -> GameCommands {
    ctx.ecs.select([LECSId.self, LECSPTimerSleep.self]) { row, columns in
      let c = counter()

      let id = row.component(at: c(), columns, LECSId.self)
      let timer = row.component(at: c(), columns, LECSPTimerSleep.self)

      if timer.expired() {
        print("awakeEvent-\(id)")
        ctx.ecs.createEvent(name: "awakeEvent-\(id)", type: .awake(id))
      }
    }

    return GameCommands()
  }
}
