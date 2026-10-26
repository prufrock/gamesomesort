//
//  LECSPOnTap.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 10/25/26.
//

import lecs_swift
import VRTMath

public struct LECSPOnTap: LECSComponent {
  public let list: Set<Action>

  public init() {
    list = []
  }

  public init (_ list: Set<Action>) {
    self.list = list
  }

  public enum Action: Equatable, Hashable {
    case exit
    case moveConstant(velocity: F3)
    case move
    case reload
  }
}
