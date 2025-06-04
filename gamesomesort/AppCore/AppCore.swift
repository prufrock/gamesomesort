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

  static func preview() -> AppCore {
    AppCore(
      AppCoreConfig(
        services: AppCoreConfig.Services(
          renderService: AppCoreConfig.Services.RenderService(
            type: .ersatz,
            clearColor: (0.3, 0.0, 0.3, 1.0)
          ),
          fileService: AppCoreConfig.Services.FileService(
            levelsFile: AppCoreConfig.Services.FileService.FileDescriptor(name: "levels", ext: .json),
          )
        )
      )
    )
  }
}

protocol ServiceCommand {}
