//
//  AppCore.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import lecs_swift
import MetalKit

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
    return GMGame(appCore: self, levels: levels)
  }

  func createWorldFactory() -> GMWorldFactory {
    GMWorldFactory(config: config)
  }

  func createControllerInput() -> ControllerInput {
    ControllerInput(config: config)
  }

  @MainActor
  func createControllerGame(view: MTKView) -> ControllerGame {
    .init(
      appCore: self,
      controllerInput: createControllerInput(),
      metalView: view
    )
  }

  static func preview() -> AppCore {
    AppCore(
      AppCoreConfig.testDefault
    )
  }

  struct GMWorldFactory {
    let config: AppCoreConfig

    func create(level: Int, levels: [GMTileMap]) -> any GMWorld {
      let map = levels[level]
      switch level {
      case 1:
        return GMWorld01(
          config: config,
          ecs: LECSCreateWorld(archetypeSize: 500),
          map: map,
          ecsStarter: selectStarter(level: level, levels: levels)
        )
      case 2:
        return GMWorld02(
          config: config,
          ecs: LECSCreateWorld(archetypeSize: 500),
          map: map,
          ecsStarter: selectStarter(level: level, levels: levels)
        )
      default:
        return GMWorld00(
          config: config,
          ecs: LECSCreateWorld(archetypeSize: 500),
          map: map,
          ecsStarter: selectStarter(level: level, levels: levels)
        )
      }

    }

    func selectStarter(level: Int, levels: [GMTileMap]) -> GMEcsStarter {
      switch level {
      case 0:
        return GMEcsInitW00(config: config)
      case 2:
        return GMEcsInitW02(map: levels[level], config: config)
      default:
        return GMEcsInitW01(map: levels[level], config: config)
      }
    }
  }
}

protocol ServiceCommand {}
