//
//  LECSTimerSleep.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 5/30/26.
//

import lecs_swift

public struct LECSPTimerSleep: LECSComponent {
  public var remaining: Float

  public init() {
    self.remaining = 0
  }

  public init(remaining: Float) {
    self.remaining = remaining
  }

  public func expired() -> Bool {
    return remaining <= 0
  }
}
