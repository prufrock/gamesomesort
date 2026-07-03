//
//  LECSPPlayerOwner.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 7/3/26.
//

import lecs_swift

public struct LECSPPlayerOwner: LECSComponent {
  public var owner: LECSId

  public init() {
    owner = LECSId(0)
  }

  public init(
    _ owner: LECSId
  ) {
    self.owner = owner
  }
}
