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

  private let steps: [GCFGWorld.StepId: Step]

  init(context: Context) {
    steps = Dictionary(uniqueKeysWithValues: context.config.world.stepList.map { key in
      switch key {
      case .awaken:
        (key, StepNoop())
      case .handleEvents:
        (key, StepNoop())
      case .handleInput:
        (key, StepNoop())
      case .physics:
        (key, Physics(context: context))
      }
    })
  }

  func run(context: Context) -> GameCommands {
    var gameCommands = GameCommands()

    context.config.world.stepList.forEach { step in
      guard let current = steps[step] else {
        return
      }
      switch step {
      case .awaken:
        gameCommands.append(awaken(context: context))
      case .handleInput:
        gameCommands.append(handleInput(context: context))
      case .handleEvents:
        gameCommands.append(handleEvents(context: context))
      case .physics:
        gameCommands.append(current.run(context: context))
      }
    }

    return gameCommands
  }

  struct Context {
    let ecs: LECSWorld
    let config: Config
    let input: TBDGame.Input
  }

  protocol Step {
    func run(context: Context) -> GameCommands
  }
}

struct StepNoop: StepSelector.Step {
  func run(context: StepSelector.Context) -> GameCommands {
    GameCommands()
  }
}
