//
//  LECSPTileName.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 11/8/26.
//

import lecs_swift

public struct LECSPTileName: LECSComponent {
  public var name: String


  public init() {
    self.name = ""
  }

  public init(name: String) {
    self.name = name
  }
}
