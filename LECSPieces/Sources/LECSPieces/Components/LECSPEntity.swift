//
//  LECSPEntity.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 11/1/26.
//

import lecs_swift

public struct LECSPEntity: LECSComponent, Hashable {
  public let type: LECSPEntityType

  public init() {
    type = .tile
  }

  public init(type: LECSPEntityType) {
    self.type = type
  }
}
