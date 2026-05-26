//
//  StepHandleEvents.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/25/26.
//

extension StepSelector {
  func handleEvents(context: Context) -> GameCommands {
    context.ecs.processEvents()
  }
}
