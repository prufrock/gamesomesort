//
//  FileService.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/3/25.
//

import Foundation

class FileService {
  fileprivate let config: AppCoreConfig

  init(_ config: AppCoreConfig) {
    self.config = config
  }

  func sync(_ command: LoadLevelFileCommand) {
    command.execute(fileService: self)
  }
}

struct LoadLevelFileCommand: ServiceCommand {
  let block: ([GMTileMap]) -> Void

  func execute(fileService: FileService) {
    let jsonUrl = Bundle.main.url(
      forResource: fileService.config.services.fileService.levelsFile.name,
      withExtension: fileService.config.services.fileService.levelsFile.ext.rawValue
    )!

    let jsonData = try! Data(contentsOf: jsonUrl)
    let levels = try! JSONDecoder().decode([GMMapData].self, from: jsonData)
    block(
      levels.enumerated().map { index, mapData in
        GMTileMap(mapData, index: index)
      }
    )
  }
}
