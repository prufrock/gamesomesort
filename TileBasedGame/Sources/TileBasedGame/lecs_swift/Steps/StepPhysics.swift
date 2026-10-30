//
//  StepPhysics.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 10/26/26.
//

import Foundation
import LECSPieces
import lecs_swift
import VRTMath

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

  private let animationSystemId: LECSSystemId

  init(context ctx: StepSelector.Context) {
    animationSystemId = ctx.ecs.addSystemWorldScoped(
      "animation",
      selector: [LECSId.self, LECSPVelocity3d.self, LECSPScale3d.self, LECSPAnimation.self, LECSPPosition3d.self]
    )
    { world, row, columns in
      // Fetch the clock for animations that need it.
      // Is there a way to store this for run each of the system?
      var clock: LECSPClock = LECSPClock()
      world.select([LECSPClock.self]) { row, columns in
        clock = row.component(at: 0, columns, LECSPClock.self)
      }

      let c = counter()
      let id = row.component(at: c(), columns, LECSId.self)
      let velocity = row.component(at: c(), columns, LECSPVelocity3d.self)
      var scale = row.component(at: c(), columns, LECSPScale3d.self)
      let animation = row.component(at: c(), columns, LECSPAnimation.self)
      var position = row.component(at: c(), columns, LECSPPosition3d.self)

      switch animation.motion {
        case .linear(let velocity):
          position = LECSPPosition3d(position.position + velocity)
        case .sine(let oscillator):
          let omega = 2.0 * Float.pi * oscillator.frequency
          let waveFactor = sin(omega * Float(clock.ticks) + oscillator.phase)
          let oscillationPosition = oscillator.amplitude * waveFactor
          if oscillator.scale {
            scale = LECSPScale3d(oscillator.anchor + oscillationPosition)
          } else {
            position = LECSPPosition3d(oscillator.anchor + oscillationPosition)
          }
      }

      return [id, velocity, scale, animation, position]
    }
  }

  func run(context ctx: StepSelector.Context) -> GameCommands {
    let ecs = ctx.ecs
    
    ecs.processSystemWorldScoped(system: animationSystemId)

    return GameCommands()
  }
}
