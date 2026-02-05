//
//  AppCore.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import MetalKit

/// AppCore is where anything that needs to be available across the application
/// should be stored or made accessible. The motiviation here is to avoid any
/// global state, so if you think something might need to be global, find a way
/// to put it in the AppCore.
class AppCore {
  /// The memory of AppCore. The place where AppCore keeps all it's stuff.
  private var context: AppCoreContext

  /// The application's configuration. This is the place to go to get it.
  var config: AppCoreConfig {
    get {
      context.config
    }
  }

  /// Creates a new AppCore with the given config.
  init(_ config: AppCoreConfig) {
    context = AppCoreContext(config: config)
  }

  /// Synchronously send a command.
  func sync(_ command: any ServiceCommand) {
    context.sync(command)
  }

  /// Create a fresh instance of GMGame.
  func createGMGame() -> GMGame {
    var levels: [GMTileMap] = []
    sync(
      LoadLevelFileCommand { maps in
        levels = maps
      }
    )
    return GMGame(appCore: self, levels: levels)
  }

  /// Create a fresh world factory.
  func createWorldFactory() -> GMWorldFactory {
    GMWorldFactory(config: config)
  }

  /// Create a fresh ControllerInput.
  func createControllerInput() -> ControllerInput {
    ControllerInput(config: config)
  }

  /// Create a fresh ControllerGame.
  /// This has to happen on the main thread, so the delegate on the MTKView
  /// can be set.
  @MainActor
  func createControllerGame(view: MTKView) -> ControllerGame {
    .init(
      appCore: self,
      controllerInput: createControllerInput(),
      metalView: view
    )
  }

  /// A version of AppCore for test and maybe previews, if it would work.
  static func preview() -> AppCore {
    AppCore(
      AppCoreConfig.testDefault
    )
  }
}
