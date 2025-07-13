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

  subscript(x: Int, y: Int) -> GMTile {
    get { tiles[y * width + x] }
  }

  subscript(thing x: Int, y: Int) -> GMThing {
    get { things[y * width + x] }
  }

  func coordinates(_ body: (Int, Int) -> Void) {
    for y in 0..<height {
      for x in 0..<width {
        body(x, y)
      }
    }
  }

  func tiles(_ body: (GMTile, (Int, Int)) -> Void) {
    coordinates { x, y in
      let tile = self[x, y]
      body(tile, (x, y))
    }
  }

  func things(_ body: (GMThing, (Int, Int)) -> Void) {
    coordinates { x, y in
      let thing = self[thing: x, y]
      body(thing, (x, y))
    }
  }
}
