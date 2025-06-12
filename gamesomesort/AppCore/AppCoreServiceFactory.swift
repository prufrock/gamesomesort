//
//  AppCoreServiceFactory.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.

/// Constructs services on demand from the config.
class AppCoreServiceFactory {
  private let config: AppCoreConfig

  init(_ config: AppCoreConfig) {
    self.config = config
  }

  func createRenderService() -> RenderService {
    RenderService(config)
  }

  func createFileService() -> FileService {
    FileService(levelsFile: config.services.fileService.levelsFile)
  }
}
