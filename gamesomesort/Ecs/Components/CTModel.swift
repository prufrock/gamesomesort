//
//  CTModel.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/10/25.
//

import lecs_swift

// Used to attached a model to an entity.
// Use "sphere" or "plane" for the primitives.
struct CTModel: LECSComponent {
  var name: String

  init() {
    name = ""
  }

  init(_ name: String) {
    self.name = name
  }
}
