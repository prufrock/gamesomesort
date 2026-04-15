//
//  GCFGWorld.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/5/26.
//

struct GCFGWorld: Decodable {
  let entities: GCFGEntities
  let levels: [String: LevelPath]
  let name: String

  struct LevelPath: Decodable {
    let name: String
    let path: String
  }
}
