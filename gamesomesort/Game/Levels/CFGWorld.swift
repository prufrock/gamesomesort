//
//  CFGWorld.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 4/2/26.
//

struct CFGWorld: Decodable {
  let world: Levels

  struct Levels: Decodable {
    let levels: [String: LevelPath]

    struct LevelPath: Decodable {
      let name: String
      let path: String
      let ext: String
    }
  }
}
