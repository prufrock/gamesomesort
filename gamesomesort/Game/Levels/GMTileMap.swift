//
//  GMTileMap.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

public struct GMTileMap {
  private(set) var tiles: [GMTile]
  private(set) var things: [GMThing]

  let width: Int
  var height: Int {
    tiles.count / width
  }
  var size: F2 {
    return F2(x: Float(width), y: Float(height))
  }

  // for switching between levels
  let index: Int

  init(_ map: GMMapData, index: Int) {
    tiles = map.tiles
    width = map.width
    things = map.things

    self.index = index
  }
}
