//
//  LECSPOnWake.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 5/31/26.
//

import lecs_swift

public struct LECSPOnWake: LECSComponent {
  public let set: Set<Action>

  public init() {
    self.set = []
  }

  public init(_ actions: Set<Action>) {
    self.set = actions
  }

  public enum Action: Decodable, Hashable {
    case creates(creatureId: String)
    case createsMoveBtns(up: Int, down: Int, left: Int, right: Int)
    case levelStart
    case nothing
    case queuesToPlayer
  }
}
