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

  @Test func testSubscriptForTilesAndThings() {
    let tileMap = simpleTileMap

    let coordinates: [(Int, Int)] = [(0, 0)]
    coordinates.forEach { (x, y) in
      #expect(tileMap[x, y] == .wall)
      #expect(tileMap[thing: x, y] == .nothing)
    }
  }

  @Test func testCoordinates() {
    let tileMap = simpleTileMap

    var expectedCoordinates = CTSQueueArray<(Int, Int)>()
    expectedCoordinates.enqueue((0, 0))

    tileMap.coordinates { x, y in
      #expect(expectedCoordinates.dequeue()! == (x, y))
    }
  }

  @Test func testTiles() {
    let tileMap = simpleTileMap

    var expectedCoordinates = CTSQueueArray<(GMTile, (Int, Int))>()
    expectedCoordinates.enqueue((.wall, (0, 0)))

    tileMap.tiles { tile, xy in
      let expected = expectedCoordinates.dequeue()!
      #expect(expected.0 == tile)
      #expect(expected.1 == xy)
    }
  }
}
