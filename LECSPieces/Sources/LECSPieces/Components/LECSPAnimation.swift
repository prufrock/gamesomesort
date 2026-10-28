//
//  LECSPAnimation.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 10/27/26.
//

import lecs_swift
import VRTMath

public struct LECSPAnimation: LECSComponent {
  public let motion: Motion

  public init() {
    motion = .linear(velocity: [0, 0, 0])
  }

  public init(motion: Motion) {
    self.motion = motion
  }

  public enum Motion {
    case linear(velocity: F3)
    case sine(velocity: F3)
  }
}
