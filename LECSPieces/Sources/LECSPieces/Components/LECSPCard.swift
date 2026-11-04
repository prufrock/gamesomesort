//
//  LECSPCard.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 11/1/26.
//

import lecs_swift
import VRTMath

public struct LECSPCard: LECSComponent {
  public var hitPoints: Int
  public var movement: Movement

  public init() {
    hitPoints = 0
    movement = Movement()
  }

  public init(hitPoints: Int, movement: Movement) {
    self.hitPoints = hitPoints
    self.movement = movement
  }

  public struct Movement {
    public var direction: Int
    public var step: Int
    public var path: [F3]

    public init() {
      self.direction = 1
      self.step = 0
      self.path = []
    }

    public init(direction: Int, step: Int, path: [F3]) {
      self.direction = direction
      self.step = step
      self.path = path
    }
  }
}
