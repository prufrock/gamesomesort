//
//  GMTileMapTests.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/13/25.
//

import Testing
@testable import gamesomesort

import Foundation
import lecs_swift

struct GMTileMapTests {
  @Test
  func example() {
    let tileMap = GMTileMap(
      GMMapData(tiles: [.wall], width: 1, things: [.nothing]),
      index: 0
    )

    #expect(tileMap.index == 0)
  }
}
