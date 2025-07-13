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
  @Test func testSubscriptForTilesAndThings() {
    let tileMap = GMTileMap(
      GMMapData(tiles: [.wall], width: 1, things: [.nothing]),
      index: 0
    )

    let coordinates: [(Int, Int)] = [(0, 0)]
    coordinates.forEach { (x, y) in
      #expect(tileMap[x, y] == .wall)
      #expect(tileMap[thing: x, y] == .nothing)
    }
  }
}
