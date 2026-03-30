//
//  FileService.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/3/25.
//

import Foundation

private typealias FileDescriptor = AppCoreConfig.Services.FileService.FileDescriptor

class FileService {
  fileprivate let levelsFile: FileDescriptor
  fileprivate let worldFiles: [String: FileDescriptor]

  init(
    levelsFile: AppCoreConfig.Services.FileService.FileDescriptor,
    worldFiles: [String: AppCoreConfig.Services.FileService.FileDescriptor]
  ) {
    self.levelsFile = levelsFile
    self.worldFiles = worldFiles
  }

  func sync(_ command: LoadLevelFileCommand) {
    command.execute(fileService: self)
  }

  func sync(_ command: LoadWorldFileCommand) {
    command.execute(fileService: self)
  }
}

struct LoadLevelFileCommand: ServiceCommand {
  let block: ([GMTileMap]) -> Void

  func execute(fileService: FileService) {
    let jsonUrl = Bundle.main.url(
      forResource: fileService.levelsFile.name,
      withExtension: fileService.levelsFile.ext.rawValue
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

struct LoadWorldFileCommand: ServiceCommand {
  let worldName: String

  func execute(fileService: FileService) {
    guard let fileDescriptor = fileService.worldFiles[worldName] else {
      fatalError(
        "Unable to load world: \(worldName)."
          + "The world file descriptor is not registered in AppCoreConfig."
      )
    }
    let jsonUrl = Bundle.main.url(
      forResource: fileDescriptor.name,
      withExtension: fileDescriptor.ext.rawValue
    )!

    let jsonData = try! Data(contentsOf: jsonUrl)
    print(jsonData.count)
  }
}
