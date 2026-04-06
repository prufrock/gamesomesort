//
//  GMTileMap.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

import VRTMath

/// I am going to start transitioning this into a "Game" level config,
/// but keep this in place while I make that happen.
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

  let worlds: [String: CFGWorldPath]

  init(_ map: GMMapData, index: Int) {
    tiles = map.tiles
    width = map.width
    things = map.things
    worlds = map.worlds ?? [:]

    self.index = index
  }

  private subscript(x: Int, y: Int) -> GMTile {
    get { tiles[y * width + x] }
  }

  private subscript(thing x: Int, y: Int) -> GMThing {
    get { things[y * width + x] }
  }

  private func coordinates(_ body: (Int, Int) -> Void) {
    for y in 0..<height {
      for x in 0..<width {
        body(x, y)
      }
    }
  }

  /// Pass each tile and thing and it's coordinates to the provided closure.
  func locations(_ body: (GMTile, GMThing, (Int, Int)) -> Void) {
    coordinates { x, y in
      let tile = self[x, y]
      let thing = self[thing: x, y]
      body(tile, thing, (x, y))
    }
  }
}
