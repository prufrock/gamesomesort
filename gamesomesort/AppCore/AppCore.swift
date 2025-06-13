//
//  AppCore.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

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
  func sync(_ command: ServiceCommand) {
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

  static func preview() -> AppCore {
    AppCore(
      AppCoreConfig.testDefault
    )
  }

  struct GMWorldFactory {
    let config: AppCoreConfig

    func create(level: Int, levels: [GMTileMap]) -> GMWorld {
      GMWorld(config: config, map: levels[level])
    }
  }
}

protocol ServiceCommand {}
