//
//  GMMapData.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

struct GMMapData: Decodable {
  let tiles: [GMTile]
  let width: Int
  let things: [GMThing]
}
