//
//  StepPhysics.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 10/26/26.
//

import LECSPieces
import lecs_swift

extension StepSelector {
  /// Apply the physical changes to the game state like the effects of velocity.
  func physics(context ctx: Context) -> GameCommands {
    let ecs = ctx.ecs
    // convert to system
    ecs.select([LECSId.self, LECSPVelocity3d.self, LECSPPosition3d.self]) { row, columns in
      let c = counter()
      let id = row.component(at: c(), columns, LECSId.self)
      let velocity = row.component(at: c(), columns, LECSPVelocity3d.self)
      var position = row.component(at: c(), columns, LECSPPosition3d.self)

      position = LECSPPosition3d(position.position + velocity.velocity)

      ecs.addComponent(id.id, position)
    }

    return GameCommands()
  }
}

struct Physics: StepSelector.Step {

  private let velocitySystemId: LECSSystemId

  init(context ctx: StepSelector.Context) {
    velocitySystemId = ctx.ecs.addSystemWorldScoped(
      "velocity",
      selector: [LECSId.self, LECSPVelocity3d.self, LECSPPosition3d.self]
    )
    { world, row, columns in
      let c = counter()
      let id = row.component(at: c(), columns, LECSId.self)
      let velocity = row.component(at: c(), columns, LECSPVelocity3d.self)
      var position = row.component(at: c(), columns, LECSPPosition3d.self)

      position = LECSPPosition3d(position.position + velocity.velocity)

      return [id, velocity, position]
    }
  }

  func run(context ctx: StepSelector.Context) -> GameCommands {
    let ecs = ctx.ecs
    
    ecs.processSystemWorldScoped(system: velocitySystemId)

    return GameCommands()
  }
}
