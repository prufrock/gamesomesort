//
//  GCFGMapData.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/5/26.
//

struct GCFGMapData: Decodable {
  let tiles: [GCFGTile]
  let width: Int
  let things: [GCFGThing]
}
