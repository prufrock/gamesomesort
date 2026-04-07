//
//  GCFGWorld.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/5/26.
//

struct GCFGWorld: Decodable {
  let name: String
  let levels: [String: LevelPath]

  struct LevelPath: Decodable {
    let name: String
    let path: String
    let ext: String
  }
}
