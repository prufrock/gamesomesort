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
      case .physics:
        gameCommands.append(physics(context: context))
      }
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
