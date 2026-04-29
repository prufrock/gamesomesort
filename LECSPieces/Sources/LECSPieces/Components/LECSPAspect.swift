//
//  LECSPAspect.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 4/20/26.
//

import lecs_swift
import VRTMath

public struct LECSPAspect: LECSComponent {
  public var aspect: Float

  public init() {
    aspect = 1.0
  }

  public init(aspect: Float) {
    self.aspect = aspect
  }
}

public extension LECSPAspect {
  static func == (lhs: LECSPAspect, rhs: Float) -> Bool {
    return lhs.aspect == rhs
  }
}
