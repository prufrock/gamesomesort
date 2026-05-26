//
//  SystemSelector.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/24/26.
//

import lecs_swift

struct StepSelector {

  func run(stepList: [Step], context: Context) -> GameCommands {
    var gameCommands = GameCommands()

    stepList.forEach { work in
      switch work {
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
    let input: TBDGame.Input
  }

  enum Step:String {
    case handleInput
    case handleEvents
  }
}
