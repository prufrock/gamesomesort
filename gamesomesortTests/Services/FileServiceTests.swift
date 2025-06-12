//
//  FileServiceTests.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/11/25.
//

import Testing
@testable import gamesomesort

struct FileServiceTests {

  @Test func loadLevels() throws {
    let fileService = FileService(
      levelsFile: AppCoreConfig.Services.FileService.FileDescriptor(name: "levels", ext: .json)
    )

    var levels: [GMTileMap] = []
    let command = LoadLevelFileCommand { maps in
      levels = maps
    }
    fileService.sync(command)
    #expect(levels.count > 0)
  }
}
