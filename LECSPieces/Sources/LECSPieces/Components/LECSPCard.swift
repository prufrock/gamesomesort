//
//  LECSPCard.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 11/1/26.
//

import lecs_swift

public struct LECSPCard: LECSComponent {
  public var hitPoints: Int

  public init() {
    hitPoints = 0
  }

  public init(hitPoints: Int) {
    self.hitPoints = hitPoints
  }
}
