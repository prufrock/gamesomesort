//
//  GCFGTileMap.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/5/26.
//

import VRTMath

public struct GCFGTileMap {
  private(set) var tiles: [GCFGTile]
  private(set) var things: [GCFGThing]

  let width: Int
  var height: Int {
    tiles.count / width
  }
  var size: F2 {
    return F2(x: Float(width), y: Float(height))
  }

  init(_ map: GCFGMapData) {
    tiles = map.tiles
    width = map.width
    things = map.things
  }

  private subscript(x: Int, y: Int) -> GCFGTile {
    get { tiles[y * width + x] }
  }

  private subscript(thing x: Int, y: Int) -> GCFGThing {
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
  func locations(_ body: (GCFGTile, GCFGThing, (Int, Int)) -> Void) {
    coordinates { x, y in
      let tile = self[x, y]
      let thing = self[thing: x, y]
      body(tile, thing, (x, y))
    }
  }
}
