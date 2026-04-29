//
//  AppCoreTests.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/11/25.
//

import Testing
import VRTMath
@testable import gamesomesort

import Foundation

struct AppCoreContextTests {

  @Test func issueResizeCommand() throws {
    let context = AppCoreContext(config: AppCoreConfig.testDefault)

    #expect(throws: Never.self) {
      context.sync(
        SVCCommandRender.Resize(
          screenDimensions: VRTMScreenDimensions()
        )
      )
    }
  }

  @Test func issueLoadFileCommand() throws {
    let context = AppCoreContext(config: AppCoreConfig.testDefault)

    #expect(throws: Never.self) {
      context.sync(
        LoadLevelFileCommand { _ -> Void in }
      )
    }
  }
}
