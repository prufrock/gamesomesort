//
//  CTThing.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 1/17/26.
//

import lecs_swift

struct CTThing: LECSComponent {
  let thing: GMThing

  init() {
    self.thing = .nothing
  }

  init(_ thing: GMThing) {
    self.thing = thing
  }
}
