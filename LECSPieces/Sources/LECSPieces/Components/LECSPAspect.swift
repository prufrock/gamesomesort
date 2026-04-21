//
//  LECSPAspect.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 4/20/26.
//

import lecs_swift

public struct LECSPAspect: LECSComponent {
  public var aspect: Float

  public init() {
    aspect = 1.0
  }

  public init(aspect: Float) {
    self.aspect = aspect
  }
}
