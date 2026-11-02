//
//  LECSPTargetCreature.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 11/1/26.
//

import lecs_swift

// The id of the creature that recieve's a button's action.
public struct LECSPButtonTarget: LECSComponent {
  public let id: LECSId
  public let type: LECSPEntityType

  public init() {
    id = LECSId()
    type = .tile
  }

  public init(id: LECSId, type: LECSPEntityType) {
    self.id = id
    self.type = type
  }
}
