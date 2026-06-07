//
//  SystemSelector.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/24/26.
//

import lecs_swift
import GameConfiguration

struct StepSelector {

  func run(stepList: [GCFGWorld.StepId], context: Context) -> GameCommands {
    var gameCommands = GameCommands()

    stepList.forEach { work in
      switch work {
      case .awaken:
        gameCommands.append(awaken(context: context))
      case .handleInput:
        gameCommands.append(handleInput(context: context))
      case .handleEvents:
        gameCommands.append(handleEvents(context: context))
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
