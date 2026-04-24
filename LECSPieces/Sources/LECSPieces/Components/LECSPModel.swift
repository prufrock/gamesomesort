//
//  LECSPModel.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 4/23/26.
//

import lecs_swift

// Used to attached a model to an entity.
// Use "sphere" or "plane" for the primitives.
public struct LECSPModel: LECSComponent {
  public var name: String

  public init() {
    name = ""
  }

  public init(_ name: String) {
    self.name = name
  }
}
