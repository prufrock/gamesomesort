//
//  AppCoreTests.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/11/25.
//

import Testing
@testable import gamesomesort

struct AppCoreTests {

  @Test func createAnAppCore() throws {
    let appCore = AppCore(AppCoreConfig.testDefault)

    #expect(appCore.config.services.fileService.levelsFile.ext.rawValue == "json")
  }
}
