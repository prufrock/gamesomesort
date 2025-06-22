//
//  AppCore.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import lecs_swift

/// The AppCore serves the global state for the application to avoid singletons(if possible):
///  - manages the state of the application
///  - provides access to services
class AppCore {
  private var context: AppCoreContext

  var config: AppCoreConfig {
    get {
      context.config
    }
  }

  init(_ config: AppCoreConfig) {
    context = AppCoreContext(config: config)
  }

  /// I'm hoping I can provide a sync and async facade over the commands services want to execute.
  func sync(_ command: any ServiceCommand) {
    context.sync(command)
  }

  func createGMGame() -> GMGame {
    var levels: [GMTileMap] = []
    sync(
      LoadLevelFileCommand { maps in
        levels = maps
      }
    )
    return GMGame(config: config, levels: levels, worldFactory: createWorldFactory())
  }

  func createWorldFactory() -> GMWorldFactory {
    GMWorldFactory(config: config)
  }

  func createControllerInput() -> ControllerInput {
    ControllerInput(config: config)
  }

  static func preview() -> AppCore {
    AppCore(
      AppCoreConfig.testDefault
    )
  }

  struct GMWorldFactory {
    let config: AppCoreConfig

    func create(level: Int, levels: [GMTileMap]) -> GMWorld {
      let level = levels[level]
      return GMWorld(
        config: config,
        ecs: LECSCreateWorld(archetypeSize: 500),
        map: level,
        ecsStarter: GMStartFromTileMap(map: level)
      )
    }
  }
}

protocol ServiceCommand {}
