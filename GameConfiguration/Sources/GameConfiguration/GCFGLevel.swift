//
//  GCFGLevel.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/6/26.
//

struct GCFGLevel: Decodable {
  let map: Map

  subscript(tile x: Int, y: Int) -> Int? {
    get { map.tiles[y * map.width + x] }
  }

  subscript(creature x: Int, y: Int) -> Int? {
    get { map.creatures[y * map.width + x] }
  }

  subscript(thing x: Int, y: Int) -> Int? {
    get { map.things[y * map.width + x] }
  }

  struct Map: Decodable {
    let width: Int
    // tiles are the walls, floors, pits, that make up the world
    let tiles: [Int]
    // creatures have behaviors like players and monsters
    let creatures: [Int]
    // for now, things are everything that isn't tiles or creatures
    let things: [Int]

    subscript(tile x: Int, y: Int) -> Int {
      get { tiles[y * width + x] }
    }

    subscript(creature x: Int, y: Int) -> Int {
      get { creatures[y * width + x] }
    }

    subscript(thing x: Int, y: Int) -> Int {
      get { things[y * width + x] }
    }
  }
}
