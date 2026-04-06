//
//  GMMapData.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

/// Like GMTileMap this is going to transition into a "Game" configuration.
struct GMMapData: Decodable {
  let tiles: [GMTile]
  let width: Int
  let things: [GMThing]
  let worlds: [String: CFGWorldPath]?
}

struct CFGWorldPath: Decodable {
  let name: String
  let path: String
}
