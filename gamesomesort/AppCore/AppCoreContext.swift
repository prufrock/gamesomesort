//
//  AppCoreContext.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

/// All of the bits that need to be shared across the application.
/// Right now this is:
/// - configuration: strings and scalars describing how different objects operate.
/// - services: objects that take commands and interact with the outside world.
class AppCoreContext {
  // The AppCoreConfig shouldn't change while the application is running.
  // If it does need to change, depending on the need, either AppCore could be reloaded or need to figure out a way
  // to reload the part of the config that changed such as a specific service.
  let config: AppCoreConfig
  private let serviceFactory: AppCoreServiceFactory
  private let renderService: RenderService
  private let fileService: FileService

  init(config: AppCoreConfig) {
    self.config = config
    serviceFactory = AppCoreServiceFactory(config)
    renderService = serviceFactory.createRenderService()
    fileService = serviceFactory.createFileService()
  }

  func sync(_ command: ServiceCommand) {
    // Mostly just an example.
    // May eventually need a way to register commands with services.
    switch command {
    case let actual as SVCCommandRender.Render:
      renderService.sync(actual)
    case let actual as SVCCommandRender.Resize:
      renderService.sync(actual)
    case let actual as SVCCommandRender.InitializePipelines:
      renderService.sync(actual)
    case let actual as LoadLevelFileCommand:
      fileService.sync(actual)
    default:
      fatalError("What in creation is this command!")
    }
  }
}
