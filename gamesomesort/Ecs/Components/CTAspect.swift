//
//  CTAspect.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/17/25.
//

import lecs_swift

struct CTAspect: LECSComponent {
  var aspect: Float

  init() {
    aspect = 1.0
  }

  init(aspect: Float) {
    self.aspect = aspect
  }
}
