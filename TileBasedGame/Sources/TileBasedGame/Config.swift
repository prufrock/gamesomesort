//
//  TBDGConfig.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 6/6/26.
//

import GameConfiguration

// Eventually this can be tucked behind a protocol.
// The static loaded configuration can be overriden with dynamic config,
// combining values from the player, feature flags, and interactive
// changes for development.
struct Config {
  let level: GCFGLevel
  let world: GCFGWorld
}
