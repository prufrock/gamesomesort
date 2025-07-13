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

  let simpleTileMap = GMTileMap(
    GMMapData(tiles: [.wall], width: 1, things: [.nothing]),
    index: 0
  )

  @Test func testLocations() {
    let tileMap = simpleTileMap

    var expectedCoordinates = CTSQueueArray<(GMTile, GMThing, (Int, Int))>()
    expectedCoordinates.enqueue((.wall, .nothing, (0, 0)))

    tileMap.locations { tile, thing, xy in
      let expected: (GMTile, GMThing, (Int, Int)) = expectedCoordinates.dequeue()!

      #expect(expected.0 == tile)
      #expect(expected.1 == thing)
      #expect(expected.2 == xy)
    }
  }
}
