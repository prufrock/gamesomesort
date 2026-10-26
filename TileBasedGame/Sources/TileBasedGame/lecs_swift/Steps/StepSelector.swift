//
//  SystemSelector.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/24/26.
//

import GameConfiguration
import lecs_swift
import LECSPieces

struct StepSelector {

  func run(context: Context) -> GameCommands {
    var gameCommands = GameCommands()

    context.config.world.stepList.forEach { work in
      switch work {
      case .awaken:
        gameCommands.append(awaken(context: context))
      case .handleInput:
        gameCommands.append(handleInput(context: context))
      case .handleEvents:
        gameCommands.append(handleEvents(context: context))
      }
    }

    // convert to system
    context.ecs.select([LECSId.self, LECSPVelocity3d.self, LECSPPosition3d.self]) { row, columns in
      let c = counter()
      let id = row.component(at: c(), columns, LECSId.self)
      let velocity = row.component(at: c(), columns, LECSPVelocity3d.self)
      var position = row.component(at: c(), columns, LECSPPosition3d.self)

      position = LECSPPosition3d(position.position + velocity.velocity)

      context.ecs.addComponent(id.id, position)
    }

    return gameCommands
  }

  struct Context {
    let ecs: LECSWorld
    let config: Config
    let input: TBDGame.Input
  }

  enum Step:String {
    case handleInput
    case handleEvents
  }
}
