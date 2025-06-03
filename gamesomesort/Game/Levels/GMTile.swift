//
//  GMTile.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

enum GMTile: Int, Decodable, CaseIterable {
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
