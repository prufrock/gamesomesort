//
//  CTLockingButton.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 1/22/26.
//

import lecs_swift

struct CTLockingButton: LECSComponent {
  var locked: Bool
  var count: Int

  init() {
    locked = false
    count = 0
  }

  init(locked: Bool, count: Int) {
    self.locked = locked
    self.count = count
  }
}
