//
//  TBDGWorldCommands.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 4/29/26.
//

public extension TBDGWorld {
  enum Commands: Equatable {
    case start(level: Int)
    case startWorld(world: String)
  }
}
