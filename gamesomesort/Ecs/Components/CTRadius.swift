//
//  CTRadius.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/19/25.
//

import lecs_swift

struct CTRadius: LECSComponent {
  var radius: Float

  init() {
    self.radius = 1.0
  }

  init(_ radius: Float) {
    self.radius = radius
  }
}
