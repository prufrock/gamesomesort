//
//  LECSWorldEvents.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/13/26.
//

import DataStructures
import LECSPieces
import lecs_swift
import VRTMath

func counter(start:Int = 0) -> () -> Int {
  var i = start
  return { defer {i += 1}; return i }
}

extension LECSWorld {
  func createEvent(name: String, type: LECSPEvent.EventType) {
    let id = createEntity(name)
    addComponent(id, LECSPEvent(event: type))
  }
}
