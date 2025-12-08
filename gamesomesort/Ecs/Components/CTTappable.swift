//
//  CTTappable.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 12/7/25.
//

import lecs_swift

/// A component for entities that tappable.
/// When it's tapped a system can change `tapped` to true. Then others can read
/// it to determine if it's been tapped.
struct CTTappable: LECSComponent {
  let tapped: Bool

  init() {
    tapped = false
  }

  init(tapped: Bool) {
    self.tapped = tapped
  }
}
