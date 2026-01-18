//
//  CTThing.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 1/17/26.
//

struct CTThing {
  let thing: GMThing

  init() {
    self.thing = .nothing
  }

  init(thing: GMThing) {
    self.thing = thing
  }
}
