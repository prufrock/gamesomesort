//
//  CTBalloonEmitter.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/27/25.
//

import lecs_swift

struct CTBalloonEmitter: LECSComponent {
  // time between emissions
  var rate: Float
  // time since last emission
  var timer: Float

  init() {
    rate = 0.0
    timer = 0.0
  }

  init(rate: Float, timer: Float = 0.0) {
    self.rate = rate
    self.timer = 0.0
  }

  mutating func update(_ delta: Float) {
    timer += delta
  }

  mutating func emit() -> Bool {
    if timer >= rate {
      timer = 0.0
      return true
    } else {
      return false
    }
  }

  private mutating func reset() {
    timer = 0.0
  }
}
