//
//  GCFGLevel.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/6/26.
//

struct GCFGLevel: Decodable {
  let name: String
  let tiles: [Int]
  let creatures: [Int]
}
