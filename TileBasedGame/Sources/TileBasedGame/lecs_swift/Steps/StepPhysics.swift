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

  private let velocitySystemId: LECSSystemId

  init(context ctx: StepSelector.Context) {
    velocitySystemId = ctx.ecs.addSystemWorldScoped(
      "velocity",
      selector: [LECSId.self, LECSPVelocity3d.self, LECSPPosition3d.self]
    )
    { world, row, columns in
      let c = counter()
      let id = row.component(at: c(), columns, LECSId.self)
      var velocity = row.component(at: c(), columns, LECSPVelocity3d.self)
      var position = row.component(at: c(), columns, LECSPPosition3d.self)

      if let animation = world.getComponent(id.id, LECSPAnimation.self), let anchor = world.getComponent(id.id, LECSPAnchorPosition.self) {
        switch animation.motion {
        case .linear(let velocity):
          position = LECSPPosition3d(position.position + velocity)
        case .sine(let s):
          // abuse velocity as the clock for now...
          let elapsedTime = velocity.x + 1
          velocity = LECSPVelocity3d([elapsedTime, 0, 0])
          let oscillationPhase: Float = 0.0
          let oscillationFrequency: Float = s.z
          let oscillationAmplitude = F2(s.x, s.y)
          let omega = 2.0 * Float.pi * oscillationFrequency
          let waveFactor = sin(omega * Float(elapsedTime) + oscillationPhase)
          let oscillationPosition = oscillationAmplitude * waveFactor
          position = LECSPPosition3d(anchor.position + F3(oscillationPosition, 0))
        }
      } else {
        position = LECSPPosition3d(position.position + velocity.velocity)
      }

      return [id, velocity, position]
    }
  }

  func run(context ctx: StepSelector.Context) -> GameCommands {
    let ecs = ctx.ecs
    
    ecs.processSystemWorldScoped(system: velocitySystemId)

    return GameCommands()
  }
}
