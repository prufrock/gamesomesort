//
//  CTTile.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 1/17/26.
//

import lecs_swift

struct CTTile: LECSComponent {
  let tile: GMTile

  init() {
    self.tile = .floor
  }

  init(_ tile: GMTile) {
    self.tile = tile
  }
}
