//
//  GCFGTile.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/5/26.
//

enum GCFGTile: Int, Decodable, CaseIterable {
  // Floors
  case floor = 0

  // Walls
  case wall = 1

  var isWall: Bool {
    switch self {
    case .wall:
      return true
    case .floor:
      return false
    }
  }
}
