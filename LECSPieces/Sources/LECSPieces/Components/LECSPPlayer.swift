//
//  LECSPTagPlayer.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 5/30/26.
//

import lecs_swift

public struct LECSPPlayer: LECSComponent {
  public var order: Int
  public var completedTurn: Bool
  public var moved: Bool

  public init() {
    self.order = 1
    self.moved = false
    self.completedTurn = false
  }

  public init(
    order: Int,
    moved: Bool,
    completedTurn: Bool
  ) {
    self.order = order
    self.moved = moved
    self.completedTurn = completedTurn
  }
}
