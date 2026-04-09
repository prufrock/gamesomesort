//
//  GCFGLevel.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/6/26.
//

struct GCFGLevel: Decodable {
  let name: String
  let map: Map

  struct Map: Decodable {
    let width: Int
    let tiles: [Int]
    let creatures: [Int]
  }
}
