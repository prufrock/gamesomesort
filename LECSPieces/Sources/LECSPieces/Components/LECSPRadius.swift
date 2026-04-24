//
//  LECSPRadius.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 4/23/26.
//

import lecs_swift

public struct LECSPRadius: LECSComponent {
  public var radius: Float

  public init() {
    self.radius = 1.0
  }

  public init(_ radius: Float) {
    self.radius = radius
  }
}
