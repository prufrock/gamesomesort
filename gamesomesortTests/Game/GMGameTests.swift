//
//  GMGameTests.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/12/25.
//

import Testing
@testable import gamesomesort

import Foundation

struct GMGameTests {

  @Test func update() throws {
    let appCore = AppCore.preview()

    let game = GMGame(
      appCore: appCore,
      levels: [GMTileMap(GMMapData(tiles: [], width: 1, things: []), index: 0)],
    )

    #expect(throws: Never.self) {
      game.update(timeStep: 0.1, input: GMGameInput())
    }
  }
}
